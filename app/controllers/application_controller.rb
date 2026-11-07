class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  helper_method :current_user

  # A record that doesn't exist (deleted, or an old link): back to the home page with a message
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, alert: "That page doesn't exist anymore.", status: :see_other
  end

  private

  def current_user
    if defined?(Current) && Current.respond_to?(:user) && Current.user.present?
      Current.user
    else
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def handle_unauthorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:alert] = "You are not authorized to perform this action (#{policy_name.humanize})."
    redirect_back_or_to root_path, status: :see_other
  end
end
