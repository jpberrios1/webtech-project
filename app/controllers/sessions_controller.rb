class SessionsController < ApplicationController
    def switch
        session[:user_id] = params[:user_id]
        redirect_back fallback_location: root_path, notice: "Session switched to #{current_user.name}"
    end
end