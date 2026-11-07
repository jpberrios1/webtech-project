class ApplicationsController < ApplicationController
    before_action :set_application, only: [ :show, :edit, :update, :destroy ]

    def index
        authorize Application
        scoped_appliations = policy_scope(Application).includes(:seeker, listing: :property)

        @applications = scoped_applications
        @received_applications = scoped_applications.joins(listing: :property).where(properties: {user_id: current_user&.id})
        @sent_applications = scoped_applications.where(seeker_id: current_user&.id)
    end

    def show
        authorize @application
    end

    def create
        @listing = Listing.find(params[:listing_id] || params.dig(:application, :listing_id))
        @application = @listing.applications.new(application_params)
        @application.seeker = current_user
        
        authorize @application

        if @application.save
            redirect_to @listing, notice: "Application sent successfully!", status: :see_other
        else
            flash.now[:alert] = @application.errors.full_messages.to_sentence
            render "listings/show", status: :unprocessable_entity
        end
    end

    def edit
        authorize @application, :update?
    end

    def update
        authorize @application, :update?

        #return change_status if params[:transition].present?   

        new_status = params.dig(:application, :status)
        success = case new_status
                  when "shortlisted" then @application.shortlist
                  when "accepted" then @application.accept
                  when "rejected" then @application.reject
                  when "withdrawn" then 
                    authorize @application, :withdraw?
                    @application.withdraw
                  else @application.update(application_params)
                  end

        if success
            redirect_to @application, notice: "Application status updated.", status: :see_other
        else
            flash.now[:alert] = @application.errors.full_messages.to_sentence.presence || "Could not update status."
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        authorize @application, :withdraw?
        
        if @application.withdraw
        redirect_to applications_path, notice: "Application withdrawn successfully", status: :see_other
        else
            redirect_to application_path, alert: @application.errors.full_messages.to_sentence, status: :see_other
        end
    end

    private

    def set_application
        @application = policy_scope(Application).find_by(id: params[:id])
        return if @application.present?

        real_record = Application.find(params[:id])
        authorize real_record, :show?
    end

    def application_params
        params.require(:application).permit(:message, :desired_move_in_date, :length_of_stay_days)
    end

    # NEW: goes back to the page the button was on (show, edit or index)
    def finish(succeeded, notice)
        if succeeded
            @applications = Application.all
            @pending_count = @applications.count(&:pending?)

            respond_to do |format|
            format.turbo_stream do
                flash.now[:notice] = notice 
                render :update_status
            end

            format.html do
                redirect_back fallback_location: application_path(@application), notice: notice, status: :see_other
            end
        end
        else
            respond_to do |format|
            format.turbo_stream do
                flash.now[:alert] = @application.errors.full_messages.to_sentence
                render :update_status, status: :unprocessable_entity
            end

            format.html do
                redirect_back fallback_location: application_path(@application), alert: @application.errors.full_messages.to_sentence, status: :see_other
            end
        end
        end
    end

    def change_status

        case params[:transition]
        when "shortlist"
            authorize @application, :shortlist?
            finish(@application.shortlist, "Application shortlisted. You can now propose a visit.")

        when "accept"
            authorize @application, :accept?
            if @application.accept
                rejected = @application.rejected_applications.size
                finish(true, "Application accepted. #{rejected} other application(s) were rejected and the listing is now reserved.")
            else
                finish(false, nil)
            end

        when "reject"
            authorize @application, :reject?
            finish(@application.reject, "Application rejected.")

        when "withdraw"
            authorize @application, :withdraw?
            finish(@application.withdraw, "Application withdrawn.")
        else
            redirect_back fallback_location: application_path(@application), alert: "Unknown action.", status: :see_other
        end
    end
end
