class NeighborhoodsController < ApplicationController

    before_action :set_neighborhood, only: [:show, :edit, :update, :destroy]

    def index
        @neighborhoods = Neighborhood.order(:name)
    end

    def show
        @neighborhood = Neighborhood.find(params[:id])
        @properties = @neighborhood.properties.includes(listings: { photos_attachments: :blob })
    end

    def new
        @neighborhood = Neighborhood.new
    end

    def create
        @neighborhood = Neighborhood.new(neighborhood_params)
        
        if @neighborhood.save
            redirect_to neighborhoods_path, notice: "Neighborhood created."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @neighborhood.update(neighborhood_params)
            redirect_to neighborhoods_path, notice: "Neighborhood updated."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @neighborhood.destroy
        redirect_to neighborhoods_path, notice: "Neighborhood deleted.", status: :see_other
    end

    private
    
    def set_neighborhood
        @neighborhood = Neighborhood.find(params[:id])
    end

    def neighborhood_params
        params.require(:neighborhood).permit(:name, :city)
    end

    def requiere_mod
        unless current_user.name.downcase.includes?("mod")
            redirect_to root_path, alert: "You are not authorized"
        end
    end
end