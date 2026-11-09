class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path,
                alert: "That page doesn't exist anymore.",
                status: :see_other
  end

  private

  def current_user
    resume_session&.user
  end

  def handle_unauthorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:alert] = "You are not authorized to perform this action (#{policy_name.humanize})."
    redirect_back_or_to root_path, status: :see_other
  end
end
