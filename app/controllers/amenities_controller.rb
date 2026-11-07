class AmenitiesController < ApplicationController

    before_action :set_amenity, only: [:show, :edit, :update, :destroy]

    def index
        @amenities = policy_scope(Amenity).order(:name)
    end

    def show
      authorize @amenity
    end

    def new
        @amenity = Amenity.new
        authorize @amenity
    end

    def create
        @amenity = Amenity.new(amenity_params)
        authorize @amenity

        if @amenity.save
            redirect_to amenities_path, notice: "Amenity created."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        authorize @amenity
    end

    def update
        authorize @amenity

        if @amenity.update(amenity_params)
            redirect_to amenities_path, notice: "Amenity updated."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        authorize @amenity
        
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

end
