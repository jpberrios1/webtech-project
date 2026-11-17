
require "test_helper"

class ApplicationNotificationMailerTest < ActionMailer::TestCase
  fixtures :users

  test "new_application sends the notification to the property owner" do
    host = users(:two)
    seeker = users(:one)

    neighborhood = Neighborhood.create!(
      name: "Test Neighborhood",
      city: "Santiago"
    )

    property = Property.create!(
      user: host,
      neighborhood: neighborhood,
      title: "Test Property",
      address: "123 Test Street",
      property_type: "apartment",
      bedrooms: 2,
      bathrooms: 1
    )

    listing = Listing.create!(
      property: property,
      title: "Available Room",
      status: :published,
      minimum_stay_days: 1,
      monthly_rent: 300000,
      deposit: 100000,
      is_furnished: true,
      has_private_bathroom: false,
      available_from: Date.current + 1.day
    )

    application = Application.create!(
      listing: listing,
      seeker: seeker,
      message: "I am interested in this room.",
      desired_move_in_date: Date.current + 2.days,
      length_of_stay_days: 30
    )

    mail = ApplicationNotificationMailer.new_application(application)

    assert_equal [host.email_address], mail.to
    assert_equal "New application for Available Room", mail.subject
    assert_equal ["from@example.com"], mail.from
    assert_match seeker.name, mail.body.encoded
    assert_match "I am interested in this room.", mail.body.encoded
  end
end
