class RoomiesController < ApplicationController
    def home
        @featured_listings = Listing.published_index.limit(5)
    end
end