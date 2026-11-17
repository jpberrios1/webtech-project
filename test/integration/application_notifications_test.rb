
require "test_helper"

class ApplicationNotificationsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  fixtures :users

  setup do
    @host = users(:two)
    @seeker = users(:one)

    neighborhood = Neighborhood.create!(
      name: "Notification Neighborhood",
      city: "Santiago"
    )

    property = Property.create!(
      user: @host,
      neighborhood: neighborhood,
      title: "Notification Property",
      address: "123 Test Street",
      property_type: "apartment",
      bedrooms: 2,
      bathrooms: 1
    )

    @listing = Listing.create!(
      property: property,
      title: "Notification Room",
      status: :published,
      minimum_stay_days: 1,
      monthly_rent: 300000,
      deposit: 100000,
      is_furnished: true,
      has_private_bathroom: false,
      available_from: Date.current + 1.day
    )

    post session_path, params: {
      email_address: @seeker.email_address,
      password: "Password123!"
    }
  end

  test "successful application enqueues and delivers a notification to the host" do
    assert_enqueued_emails 1 do
      post listing_applications_path(@listing), params: {
        application: {
          message: "I am interested in this room.",
          desired_move_in_date: Date.current + 2.days,
          length_of_stay_days: 30
        }
      }
    end

    perform_enqueued_jobs

    assert_redirected_to @listing

    email = ActionMailer::Base.deliveries.last

    assert_not_nil email
    assert_equal [@host.email_address], email.to
    assert_equal "New application for Notification Room", email.subject
  end

  test "invalid application does not enqueue a notification" do
    assert_no_enqueued_emails do
      post listing_applications_path(@listing), params: {
        application: {
          message: "",
          desired_move_in_date: Date.current + 2.days,
          length_of_stay_days: 30
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
