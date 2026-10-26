class VisitsController < ApplicationController

    before_action :set_visit, only: [:show, :edit, :update, :destroy]

    def index
        @visits = Visit.order(:scheduled_at)
    end

    def show
       #@neighborhood = Neighborhood.find(params[:id])
        #@properties = @neighborhood.properties.includes(listings: :listing_photos)
    end

    def new
        @visit = Visit.new
    end

    def create
        @visit = Visit.new(visit_params)
        
        if @visit.save
            redirect_to application_path(@visit.application), notice: "Visit created."
        else
            flash.now[:alert] = "Please fix the errors below"
            redirect_to edit_application_path(@visit.application), alert: @visit.errors.full_messages.to_sentence, status: :see_other
        end
    end

    def edit
    end

    def update
        if @visit.update(visit_params)
            redirect_to application_path(@visit.application), notice: "Visit status updated.", status: :see_other
        else
            flash.now[:alert] = "Please fix the errors below"
            redirect_to application_path(@visit.application), alert: "Error updating visit.", status: :see_other
        end
    end

    def destroy
        app = @visit.application
        @visit.destroy
        redirect_to application_path(app), notice: "Visit deleted.", status: :see_other
    end

    private
    
    def set_visit
        @visit = Visit.find(params[:id])
    end

    def visit_params
        params.require(:visit).permit(:scheduled_at, :status, :application_id)
    end
end