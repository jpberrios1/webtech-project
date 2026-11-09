class PropertyPolicy < BasePolicy

    def index?
        true
    end

    def show? 
        true
    end

    def create?
        user.present?
    end

    def update?
        user.present? && (user.moderator? || record.user == user)
    end

    def destroy?
        update?
    end

    class Scope < BasePolicy::Scope
        def resolve
            scope.all
        end
    end
end