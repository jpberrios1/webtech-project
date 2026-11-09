class ReportPolicy < BasePolicy
    def index?
        user&.moderator?
    end

    def show?
        user.present? && (user.moderator? || record.user == user)
    end

    def create?
        user.present?
    end

    def update?
        user&.moderator?
    end

    def destroy?
        user&.moderator?
    end

    class Scope < BasePolicy::Scope
        def resolve
            return scope.none if user.nil?
            return scope.all if user.moderator?
            scope.where(user_id: user.id)
        end
    end
end
