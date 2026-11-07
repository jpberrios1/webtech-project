# GET /api/v1/amenities
# The catalog, so a client (like the search page) can fill its amenities filter.
module Api
  module V1
    class AmenitiesController < BaseController
      def index
        amenities = Amenity.order(:name)
        render json: { data: amenities.map { |amenity| amenity_document(amenity) } }
      end

      private

      def amenity_document(amenity)
        { id: amenity.id, name: amenity.name, description: amenity.description }
      end
    end
  end
end
