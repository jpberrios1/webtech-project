# GET /api/v1/shared_spaces
# The catalog, so a client (like the search page) can fill its shared spaces filter.
module Api
  module V1
    class SharedSpacesController < BaseController
      def index
        shared_spaces = SharedSpace.order(:name)
        render json: { data: shared_spaces.map { |shared_space| shared_space_document(shared_space) } }
      end

      private

      def shared_space_document(shared_space)
        { id: shared_space.id, name: shared_space.name, description: shared_space.description }
      end
    end
  end
end
