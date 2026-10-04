class PropertiesController < ApplicationController

    def index
        @properties = Property.includes(:neighborhood, :user).all
    end 

    def show
        @property = Property.with_details.find(params[:id])
    end

end