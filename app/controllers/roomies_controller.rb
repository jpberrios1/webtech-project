class RoomiesController < ApplicationController
    allow_unauthenticated_access only: [ :home ]
    skip_after_action :verify_authorized, only: [ :home ], raise: false
    skip_after_action :verify_policy_scoped, only: [ :home ], raise: false
    
    def home
        @featured_listings = Listing.published_index.limit(5)
    end
end
