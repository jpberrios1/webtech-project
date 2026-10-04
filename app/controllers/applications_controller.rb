class ApplicationsController < ApplicationController

    def index
        @applications = Application.includes(listing: :property, seeker: nil).order(created_at: :desc)
    end

    def show
        @application = Application.includes(:visits, listing: :property, seeker: nil).find(params[:id])
    end

end