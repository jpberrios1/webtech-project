class ApplicationsController < ApplicationController

    before_action :set_application, only: [:show, :edit, :update, :destroy]

    def index
        #@applications = Application.includes(listing: :property, seeker: nil).order(created_at: :desc)
        @applications = Application.all
    end

    def show
    end

    def create
        @listing = Listing.find(params[:listing_id])
        @application = @listing.applications.build(application_params)
        @application.seeker = current_user
        @application.status = "pending"

        if @application.save
            redirect_to @listing, notice: "Application sent successfully!"
        else
            flash.now[:alert] = "Please fix the errors below"
            render "listings/show", status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @application.update(application_params)
            redirect_to @application, notice: "Application status updated."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @application.destroy
        redirect_to applications_path, notice: "Application withdrawn successfully", status: :see_other
    end

    private

    def set_application
        @application = Application.find(params[:id])
    end

    def application_params
        params.require(:application).permit(:message, :desired_move_in_date, :length_of_stay_days, :status)
    end

end