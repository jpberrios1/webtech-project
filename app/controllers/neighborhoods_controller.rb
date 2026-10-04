class NeighborhoodsController < ApplicationController

    def index
        @neighborhoods = Neighborhood.order(:name)
    end

    def show
        @neighborhood = Neighborhood.find(params[:id])
        @properties = @neighborhood.properties.includes(listings: :listing_photos)
    end

end