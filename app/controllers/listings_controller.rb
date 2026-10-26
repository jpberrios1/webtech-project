class ListingsController < ApplicationController

  before_action :set_listing, only: [:show, :edit, :update, :destroy]

  def index
    @listings = Listing.published_index 
  end

  def show
    @application = Application.new
  end

  def new
    @property = Property.find(params[:property_id])
    @listing = @property.listings.build
  end

  def create
    @property = Property.find(params[:property_id])
    @listing = @property.listings.build(listing_params)
    @listing.status = "draft"

    if @listing.save
      redirect_to @listing, notice: "Listing drafted successfully."
    else
      flash.now[:alert] = "Please fix the errors below"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: "Listing was successfully updated."
    else
      flash.now[:alert] = "Please fix the errors below"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to properties_path, notice: "Listing was successfully deleted.", status: :see_other
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(:title, :monthly_rent, :deposit, :available_from, :minimum_stay_days,
                                    :is_furnished, :has_private_bathroom, :description, :house_rules, photos: [])
  end
end