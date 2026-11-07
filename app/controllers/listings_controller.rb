class ListingsController < ApplicationController
  before_action :set_listing, only: [ :show, :edit, :update, :destroy ]

  def index
    @listings = policy_scope(Listing).where(status: "published")
  end

  def show
    @application = Application.new
    authorize @listing
  end

  def new
    @property = Property.find(params[:property_id]) if params[:property_id]
    @listing = @property ? @property.listings.new : Listing.new
    authorize @listing
  end

  def create
    @property = Property.find(params[:property_id] || params.dig(:listing, :property_id))
    @listing = @property.listings.new(listing_params)
    authorize @listing

    if @listing.save
      redirect_to @listing, notice: "Listing drafted successfully.", status: :see_other
    else
      flash.now[:alert] = "Please fix the errors below"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @listing
  end

  def update
    authorize @listing

    new_status = params.dig(:listing, :status)
    success = case new_status
              when "published" then @listing.publish
              when "withdrawn" then @listing.withdraw
              when "rented" then @listings.mark_as_rented
              else @listing.update(listing_params)
              end


    if success
      redirect_to @listing, notice: "Listing was successfully updated.", status: :see_other
    else
      redirect_to @listing, alert: @listing.errors.full_messages.to_sentence.presence || "Could not update listing.", status: :see_other
    end
  end

  def destroy
    authorize @listing
    property = @listing.property
    @listing.destroy
    redirect_to property_path(property), notice: "Listing was successfully deleted.", status: :see_other
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(:title, :monthly_rent, :deposit, :available_from, :minimum_stay_days,
                                     :is_furnished, :has_private_bathroom, :description, :house_rules, :status, photos: [])
  end
    
  def finish(succeeded, notice)
    if succeeded
      redirect_to @listing, notice: notice, status: :see_other
    else
      redirect_to @listing, alert: @listing.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def change_status
    case params[:transition]
    when "publish"
      authorize @listing, :publish?
      finish(@listing.publish, "Listing published. It is now visible to everyone")

    when "withdraw"
      authorize @listing, :withdraw?
      finish(@listing.withdraw, "Listing withdrawn. Its open applications were rejected.")

    when "mark_as_rented"
      authorize @listing, :mark_as_rented?
      finish(@listing.mark_as_rented, "Listing marked as rented.")
    else
      redirect_to @listing, alert: "Unknown action.", status: :see_other
    end
end
