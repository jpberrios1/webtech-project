class NeighborhoodsController < ApplicationController
    before_action :set_neighborhood, only: [ :show, :edit, :update, :destroy ]

    def index
        @neighborhoods = policy_scope(Neighborhood).order(:name)
    end

    def show
        authorize @neighborhood
        @properties = @neighborhood.properties.includes(listings: { photos_attachments: :blob })
    end

    def new
        @neighborhood = Neighborhood.new
        authorize @neighborhood
    end

    def create
        @neighborhood = Neighborhood.new(neighborhood_params)
        authorize @neighborhood

        if @neighborhood.save
            redirect_to neighborhoods_path, notice: "Neighborhood created."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        authorize @neighborhood
    end

    def update
        authorize @neighborhood
        if @neighborhood.update(neighborhood_params)
            redirect_to neighborhoods_path, notice: "Neighborhood updated."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        authorize @neighborhood
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
end
