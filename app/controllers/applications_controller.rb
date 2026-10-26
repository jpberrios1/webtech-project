class ApplicationsController < ApplicationController
    before_action :set_application, only: [ :show, :edit, :update, :destroy ]

    def index
        # @applications = Application.includes(listing: :property, seeker: nil).order(created_at: :desc)
        @applications = Application.all
    end

    def show
    end

    def create
        @listing = Listing.find(params[:listing_id])
        @application = @listing.applications.build(application_params)
        @application.seeker = current_user
        @application.status = "pending"

        if @application.save
            redirect_to @listing, notice: "Application sent successfully!"
        else
            flash.now[:alert] = "Please fix the errors below"
            render "listings/show", status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        return change_status if params[:transition].present?   # NEW

        if @application.update(application_params)
            redirect_to @application, notice: "Application status updated."
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @application.destroy
        redirect_to applications_path, notice: "Application withdrawn successfully", status: :see_other
    end

    private

    def set_application
        @application = Application.find(params[:id])
    end

    def application_params
        params.require(:application).permit(:message, :desired_move_in_date, :length_of_stay_days)
    end

    # NEW: goes back to the page the button was on (show, edit or index)
    def finish(succeeded, notice)
        if succeeded
            redirect_back fallback_location: application_path(@application), notice: notice, status: :see_other
        else
            redirect_back fallback_location: application_path(@application),
                          alert: @application.errors.full_messages.to_sentence, status: :see_other
        end
    end

    # NEW
    def deny(message)
        redirect_back fallback_location: application_path(@application), alert: message, status: :see_other
    end

    def change_status
        host   = @application.listing.hosted_by?(current_user)
        seeker = @application.seeker == current_user

        case params[:transition]
        when "shortlist"
            return deny("Only the host of this listing can shortlist applications.") unless host

            finish(@application.shortlist, "Application shortlisted. You can now propose a visit.")
        when "accept"
            return deny("Only the host of this listing can accept applications.") unless host

            if @application.accept
                rejected = @application.rejected_applications.size
                finish(true, "Application accepted. #{rejected} other application(s) were rejected and the listing is now reserved.")
            else
                finish(false, nil)
            end
        when "reject"
            return deny("Only the host of this listing can reject applications.") unless host

            finish(@application.reject, "Application rejected.")
        when "withdraw"
            return deny("Only the applicant can withdraw this application.") unless seeker

            finish(@application.withdraw, "Application withdrawn.")
        else
            deny("Unknown action.")
        end
    end
end
