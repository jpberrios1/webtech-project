class VisitsController < ApplicationController
    before_action :set_visit, only: [ :show, :edit, :update, :destroy ]

    def index
        authorize Visit
        @visits = policy_scope(Visit).order(:scheduled_at)
    end

    def show
        authorize @visit
    end

    def new
        @visit = Visit.new
        authorize @visit
    end

    # CHANGED: the host proposes a visit. The model only allows it on a shortlisted application.
    def create
        application = Application.find(params[:visit][:application_id])
        @visit = application.visits.build(visit_params)
        authorize @visit

        if @visit.save
            redirect_to application_path(application), notice: "Visit proposed.", status: :see_other
        else
            redirect_to edit_application_path(application), alert: @visit.errors.full_messages.to_sentence, status: :see_other
        end
    end

    def edit
        authorize @visit
    end

    # CHANGED: with a transition it's a button (confirm, cancel, complete);
    # without one it's the edit form, and changing the date means rescheduling.
    def update
        authorize @visit
        return change_status if params[:transition].present?

        new_status = params.dig(:visit, :status)
        new_date = params.dig(:visit, :scheduled_at)

        success = if new_date.present? && new_date.to_time != @visit.scheduled_at
                @visit = @visit.reschedule(new_date)
                @visit.present?
            elsif new_status == "confirmed"
                @visit.confirm
            elsif new_status == "completed"
                @visit.complete
            else
                @visit.update(visit_params)
            end

        if success
            redirect_to application_path(@visit.application), notice: "Visit rescheduled. The applicant has to confirm the new date.", status: :see_other
        else
            flash.now[:alert] = "Please fix the errors below"
            redirect_to application_path(@visit.application), alert: @visit.errors.full_messages.to_sentence.presence || "Invalid visit transition", status: :see_other
        end
    end

    def destroy
        authorize @visit
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
    def finish(succeeded, notice)
        if succeeded
            redirect_to application_path(@visit.application), notice: notice, status: :see_other
        else
            redirect_to application_path(@visit.application), alert: @visit.errors.full_messages.to_sentence, status: :see_other
        end
    end

    # NEW: only these three values are accepted
    def change_status
        case params[:transition]
        when "confirm"
            authorize @visit, :confirm?
            finish(@visit.confirm, "Visit confirmed.")

        when "cancel"
            authorize @visit, :cancel?
            finish(@visit.cancel, "Visit cancelled.")

        when "complete"
            authorize @visit, :complete?
            finish(@visit.complete, "Visit marked as completed. The applicant can now review the property.")
        else
            redirect_to application_path(@visit.application), alert: "Unknown action.", status: :see_other
        end
    end
end
