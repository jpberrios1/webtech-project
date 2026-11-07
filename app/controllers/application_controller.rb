class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path,
                alert: "That page doesn't exist anymore.",
                status: :see_other
  end

  def current_user
    Current.user
  end
end