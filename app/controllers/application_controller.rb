class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  stale_when_importmap_changes

  after_action :verify_authorized, unless: -> { action_name == "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" }

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
    action_name = exception.query.to_s.delete("?")
    @error_message = "You are not authorized to #{action_name} this #{policy_name.downcase.sub(' policy', '')}."
    flash.now[:alert] = @error_message

    respond_to do |format|
      format.html { render "shared/unauthorized", status: :forbidden }
      format.turbo_stream { render "shared/unauthorized", status: :forbidden, formats: [:html] }
      format.json { render json: { error: @error_message }, status: :forbidden }
    end
  end
end
