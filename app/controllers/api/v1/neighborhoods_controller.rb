# GET /api/v1/neighborhoods
# The catalog, so a client (like the search page) can fill its neighborhood filter.
module Api
  module V1
    class NeighborhoodsController < BaseController
      def index
        neighborhoods = Neighborhood.order(:city, :name)
        render json: { data: neighborhoods.map { |neighborhood| neighborhood_document(neighborhood) } }
      end

      private

      def neighborhood_document(neighborhood)
        { id: neighborhood.id, name: neighborhood.name, city: neighborhood.city }
      end
    end
  end
end
