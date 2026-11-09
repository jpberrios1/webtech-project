class ReviewPolicy < BasePolicy

    def index?
        true
    end

    def show?
        true
    end

    def create?
        return false if user.nil? || record.is_a?(Class)

        if record.visit.present?
            record.visit.completed? && record.visit.application.seeker == user
        elsif record.property.present?
            Visit.joins(application: :listing).exists?(
                status: "completed",
                applications: {seeker_id: user.id},
                listings: {property_id: record.property.id}
            )
        else
            false
        end
    end

    def update?
        user.present? && (record.user == user || user.moderator?)
    end

    def destroy?
        user.present? && (record.user == user || user.moderator?)
    end

    class Scope < BasePolicy::Scope
        def resolve
            scope.all
        end
    end
end