class RoomiesController < ApplicationController
    allow_unauthenticated_access only: [:home]
    def home
        @featured_listings = Listing.published_index.limit(5)
    end
end
