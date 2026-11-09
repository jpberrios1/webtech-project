class SavedListingPolicy < BasePolicy
    def index?
        user.present?
    end

    def create?
        user.present?
    end

    def destroy?
        user.present? && record.user == user
    end

    class Scope < BasePolicy::Scope
        def resolve
            return scope.none if user.nil?
            scope.where(user_id: user.id)
        end
    end
end
