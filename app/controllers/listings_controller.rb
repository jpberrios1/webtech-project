class ListingsController < ApplicationController
  before_action :set_listing, only: [ :show, :edit, :update, :destroy ]
  before_action :require_visible, only: [ :show ]

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
    return change_status if params[:transition].present?

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

  def require_visible
    return if @listing.visible_to?(current_user)

    redirect_to listings_path, alert: "That listing is not available.", status: :see_other
  end

  def listing_params
    params.require(:listing).permit(:title, :monthly_rent, :deposit, :available_from, :minimum_stay_days,
                                    :is_furnished, :has_private_bathroom, :description, :house_rules, photos: [])
  end

  def finish(succeeded, notice)
    if succeeded
      redirect_to @listing, notice: notice, status: :see_other
    else
      redirect_to @listing, alert: @listing.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def deny(message)
    redirect_to @listing, alert: message, status: :see_other
  end

  def change_status
    case params[:transition]
    when "publish"
      return deny("Only the host can publish this listing.") unless @listing.hosted_by?(current_user)

      finish(@listing.publish, "Listing published. It is now visible to everyone.")
    when "withdraw"
      unless @listing.hosted_by?(current_user) || current_user.moderator?
        return deny("Only the host or a moderator can withdraw this listing.")
      end

      finish(@listing.withdraw, "Listing withdrawn. Its open applications were rejected.")
    when "mark_as_rented"
      return deny("Only the host can mark this listing as rented.") unless @listing.hosted_by?(current_user)

      finish(@listing.mark_as_rented, "Listing marked as rented.")
    else
      deny("Unknown action.")
    end
  end
end
