
class ApplicationNotificationMailer < ApplicationMailer
  def new_application(application)
    @application = application
    @listing = application.listing
    @property = @listing.property
    @seeker = application.seeker
    @host = @property.user

    mail(
      to: @host.email_address,
      subject: "New application for #{@listing.title}"
    )
  end
end
