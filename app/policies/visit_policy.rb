class VisitPolicy < BasePolicy

    def index?
        user.present?
    end

    def show?
        host_or_applicant? || user&.moderator?
    end

    def create?
        host_or_applicant?
    end

    def update?
        host_or_applicant?
    end

    def destroy?
        host_or_applicant?
    end

    def confirm?
        user.present? && record.application.seeker == user
    end

    def complete?
        user.present? && record.application.listing.property.user == user
    end

    def cancel?
        host_or_applicant?
    end

    class Scope < BasePolicy::Scope
        def resolve
            return scope.none if user.nil?
            return scope.all if user.moderator?

            scope.joins(application: {listing: :property}).where("applications.seeker_id = :uid OR properties.user_id = :uid",
                                                                 uid: user.id).distinct
        end
    end

    private

    def host_or_applicant?
        return false if user.nil? || record.is_a?(Class) || record.application.nil?
        record.application.listing.property.user == user || record.application.seeker == user
    end
end