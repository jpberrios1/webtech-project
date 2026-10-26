class VisitsController < ApplicationController
    before_action :set_visit, only: [ :show, :edit, :update, :destroy ]
    before_action :require_host, only: [ :edit, :destroy ]   # NEW: rescheduling and deleting are for the host

    def index
        @visits = Visit.order(:scheduled_at)
    end

    def show
      # @neighborhood = Neighborhood.find(params[:id])
      # @properties = @neighborhood.properties.includes(listings: :listing_photos)
    end

    def new
        @visit = Visit.new
    end

    # CHANGED: the host proposes a visit. The model only allows it on a shortlisted application.
    def create
        application = Application.find(params[:visit][:application_id])

        unless application.listing.hosted_by?(current_user)
            return redirect_to application_path(application), alert: "Only the host can propose a visit.", status: :see_other
        end

        @visit = application.visits.build(visit_params)

        if @visit.save
            redirect_to application_path(application), notice: "Visit proposed.", status: :see_other
        else
            redirect_to edit_application_path(application), alert: @visit.errors.full_messages.to_sentence, status: :see_other
        end
    end

    def edit
    end

    # CHANGED: with a transition it's a button (confirm, cancel, complete);
    # without one it's the edit form, and changing the date means rescheduling.
    def update
        return change_status if params[:transition].present?

        new_visit = @visit.reschedule(visit_params[:scheduled_at])

        if new_visit
            redirect_to application_path(@visit.application), notice: "Visit rescheduled. The applicant has to confirm the new date.", status: :see_other
        else
            flash.now[:alert] = "Please fix the errors below"
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        app = @visit.application
        @visit.destroy
        redirect_to application_path(app), notice: "Visit deleted.", status: :see_other
    end

    private

    def set_visit
        @visit = Visit.find(params[:id])
    end

    # CHANGED: only the date. The status changes through change_status, and the
    # application is taken from the form in create, after checking the host.
    def visit_params
        params.require(:visit).permit(:scheduled_at)
    end

    # NEW
    def host?
        @visit.application.listing.hosted_by?(current_user)
    end

    # NEW
    def seeker?
        @visit.application.seeker == current_user
    end

    # NEW
    def require_host
        return if host?

        redirect_to application_path(@visit.application), alert: "Only the host can do that.", status: :see_other
    end

    # NEW
    def finish(succeeded, notice)
        if succeeded
            redirect_to application_path(@visit.application), notice: notice, status: :see_other
        else
            redirect_to application_path(@visit.application), alert: @visit.errors.full_messages.to_sentence, status: :see_other
        end
    end

    # NEW
    def deny(message)
        redirect_to application_path(@visit.application), alert: message, status: :see_other
    end

    # NEW: only these three values are accepted
    def change_status
        case params[:transition]
        when "confirm"
            return deny("Only the applicant can confirm a visit.") unless seeker?

            finish(@visit.confirm, "Visit confirmed.")
        when "cancel"
            return deny("You are not part of this visit.") unless host? || seeker?

            finish(@visit.cancel, "Visit cancelled.")
        when "complete"
            return deny("Only the host can mark a visit as completed.") unless host?

            finish(@visit.complete, "Visit marked as completed. The applicant can now review the property.")
        else
            deny("Unknown action.")
        end
    end
end
