require "ostruct"

class ApplicationNotificationMailerPreview < ActionMailer::Preview
  def new_application
    host = OpenStruct.new(
      name: "Alex Host",
      email_address: "host@example.com"
    )

    seeker = OpenStruct.new(name: "Sam Seeker")

    property = OpenStruct.new(user: host)

    listing = OpenStruct.new(
      title: "Sunny Room in Santiago",
      property: property
    )

    application = OpenStruct.new(
      listing: listing,
      seeker: seeker,
      message: "I am interested in this room.",
      desired_move_in_date: Date.current + 2.days,
      length_of_stay_days: 30
    )

    ApplicationNotificationMailer.new_application(application)
  end
end