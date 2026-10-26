class PropertiesController < ApplicationController

    before_action :set_property, only: [:show, :edit, :update, :destroy]

    def index
        @properties = Property.includes(:neighborhood, :user).all
    end 

    def show
    end

    def new
        @property = Property.new
    end

    def create
        @property = Property.new(property_params)
        @property.user = current_user

        if @property.save
            redirect_to @property, notice: "Property created successfully."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @property.update(property_params)
            redirect_to @property, notice: "Property was succesfully updated."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @property.destroy
        redirect_to properties_path, notice: "Property was succesfully deleted.", status: :see_other
    end

    private 

    def set_property
        @property = Property.find(params[:id])
    end

    def property_params
        params.require(:property).permit(:title, :address, :neighborhood_id, :property_type, :bedrooms, :bathrooms,
                       amenity_ids: [], shared_space_ids: [])
    end
end