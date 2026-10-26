class AmenitiesController < ApplicationController

    before_action :require_mod, :set_amenity, only: [:show, :edit, :update, :destroy]

    def index
        @amenities = Amenity.order(:name)
    end

    def show
       #@neighborhood = Neighborhood.find(params[:id])
        #@properties = @neighborhood.properties.includes(listings: :listing_photos)
    end

    def new
        @amenity = Amenity.new
    end

    def create
        @amenity = Amenity.new(amenity_params)
        
        if @amenity.save
            redirect_to amenities_path, notice: "Amenity created."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @amenity.update(amenity_params)
            redirect_to amenities_path, notice: "Amenity updated."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @amenity.destroy
        redirect_to amenities_path, notice: "Amenity deleted.", status: :see_other
    end

    private
    
    def set_amenity
        @amenity = Amenity.find(params[:id])
    end

    def amenity_params
        params.require(:amenity).permit(:name, :city)
    end

    def require_mod
        unless current_user.name.downcase.include?("mod")
            redirect_to root_path, alert: "You are not authorized."
        end
    end
end