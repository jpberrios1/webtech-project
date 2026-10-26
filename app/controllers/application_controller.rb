class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  # A record that doesn't exist (deleted, or an old link): back to the home page with a message
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, alert: "That page doesn't exist anymore.", status: :see_other
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) || User.first
  end
end
