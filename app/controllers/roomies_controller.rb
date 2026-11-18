class RoomiesController < ApplicationController
    allow_unauthenticated_access only: [ :home ]
    skip_after_action :verify_authorized, only: [ :home ], raise: false
    skip_after_action :verify_policy_scoped, only: [ :home ], raise: false

    def home
        @featured_listings = Listing.published_index.limit(5)
        # For the search form, which sends the visitor to the search page with the filters in the URL
        @neighborhoods = Neighborhood.order(:city, :name)
    end
end
