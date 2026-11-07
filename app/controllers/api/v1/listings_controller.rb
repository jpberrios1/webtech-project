# GET /api/v1/listings      published listings, with filters, sorting and pagination
# GET /api/v1/listings/:id  one published listing with its full details
#
# Only published listings are reachable. A draft, reserved, rented or withdrawn listing
# answers 404, the same as an id that doesn't exist, so the API doesn't reveal that it exists.
module Api
  module V1
    class ListingsController < BaseController
      DEFAULT_PER_PAGE = 20
      MAX_PER_PAGE = 50

      SORTS = {
        "available_from" => { available_from: :asc },
        "rent_asc" => { monthly_rent: :asc },
        "rent_desc" => { monthly_rent: :desc },
        "newest" => { published_at: :desc }
      }.freeze

      def index
        listings = filtered_listings.order(SORTS.fetch(sort_param)).order(:id)

        page = page_param
        per_page = per_page_param
        total_count = listings.count

        listings = listings.offset((page - 1) * per_page)
                           .limit(per_page)
                           .with_attached_photos
                           .preload(property: [ :neighborhood, :amenities, :shared_spaces ])

        render json: {
          data: listings.map { |listing| listing_document(listing) },
          meta: { page: page, per_page: per_page, total_count: total_count, total_pages: (total_count.to_f / per_page).ceil }
        }
      end

      def show
        listing = Listing.published.with_room_details.find(params[:id])
        render json: { data: listing_details_document(listing) }
      end

      private

      # Each filter is applied only when its parameter is present (an empty value is ignored,
      # which is what an untouched field of the search form sends)
      def filtered_listings
        listings = Listing.published
        listings = listings.in_neighborhood(integer_param(:neighborhood_id)) if params[:neighborhood_id].present?
        listings = listings.over_rent(decimal_param(:min_rent)) if params[:min_rent].present?
        listings = listings.under_rent(decimal_param(:max_rent)) if params[:max_rent].present?
        listings = listings.available_by(date_param(:available_by)) if params[:available_by].present?
        listings = listings.with_amenities(ids_param(:amenity_ids)) if params[:amenity_ids].present?
        listings = listings.with_shared_spaces(ids_param(:shared_space_ids)) if params[:shared_space_ids].present?
        listings = listings.where(is_furnished: boolean_param(:furnished)) if params[:furnished].present?
        listings = listings.where(has_private_bathroom: boolean_param(:private_bathroom)) if params[:private_bathroom].present?
        listings
      end

      # A list of ids. Accepts both ?amenity_ids[]=1&amenity_ids[]=2 and ?amenity_ids=1,2
      def ids_param(name)
        raw = params[name]
        values = raw.is_a?(Array) ? raw : raw.to_s.split(",")
        values.map { |value| integer_param(name, value) }.uniq
      end

      def sort_param
        sort = params[:sort].presence || "available_from"
        return sort if SORTS.key?(sort)

        raise ActionController::BadRequest, "sort must be one of: #{SORTS.keys.join(', ')}"
      end

      def page_param
        params[:page].present? ? integer_param(:page) : 1
      end

      def per_page_param
        return DEFAULT_PER_PAGE if params[:per_page].blank?

        per_page = integer_param(:per_page)
        raise ActionController::BadRequest, "per_page can't be more than #{MAX_PER_PAGE}" if per_page > MAX_PER_PAGE

        per_page
      end

      # --- Documents ------------------------------------------------------------------
      # The document of a listing, used by both index and show.
      #
      # This is an allow-list: only what is written here leaves the server. On purpose it
      # leaves out everything that identifies a person or their home: the host (name, email,
      # phone, id), the property's exact address, and anything about applications or reports.
      def listing_document(listing)
        property = listing.property

        {
          id: listing.id,
          title: listing.title,
          status: listing.status,
          monthly_rent: listing.monthly_rent.to_f,
          deposit: listing.deposit.to_f,
          available_from: listing.available_from,
          minimum_stay_days: listing.minimum_stay_days,
          furnished: listing.is_furnished,
          private_bathroom: listing.has_private_bathroom,
          published_at: listing.published_at,
          neighborhood: { id: property.neighborhood.id, name: property.neighborhood.name, city: property.neighborhood.city },
          property: {
            property_type: property.property_type,
            bedrooms: property.bedrooms,
            bathrooms: property.bathrooms,
            amenities: property.amenities.map { |amenity| { id: amenity.id, name: amenity.name } },
            shared_spaces: property.shared_spaces.map { |space| { id: space.id, name: space.name } }
          },
          cover_photo_url: listing.photos.attached? ? rails_representation_url(listing.photos.first.variant(:card)) : nil,
          url: listing_url(listing)
        }
      end

      # The document of one listing in show: the same fields plus its texts, photos and reviews.
      def listing_details_document(listing)
        # Reviews are sorted in Ruby (not with .order) because with_room_details already loaded them
        reviews = listing.property.reviews.sort_by(&:created_at).reverse

        listing_document(listing).merge(
          description: listing.description.to_plain_text,
          house_rules: listing.house_rules.to_plain_text,
          photos: listing.photos.map do |photo|
            { url: rails_blob_url(photo), large_url: rails_representation_url(photo.variant(:large)) }
          end,
          reviews_summary: {
            count: reviews.size,
            average_rating: reviews.any? ? (reviews.sum(&:rating).to_f / reviews.size).round(1) : nil
          },
          # Who wrote a review is personal data, so only the rating, comment and date are shown
          reviews: reviews.map do |review|
            { rating: review.rating, comment: review.comment, created_at: review.created_at }
          end
        )
      end
    end
  end
end
