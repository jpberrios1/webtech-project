class ListingsController < ApplicationController
  def index
    @listings = Listing.published_index 
  end

  def show
    @listing = Listing.with_room_details.find(params[:id]) 
  end
end