class NeighborhoodPolicy < BasePolicy
    def index?
        true
    end

    def show?
        true
    end

    def create?
        user&.moderator?
    end

    def update?
        user&.moderator?
    end

    def destroy?
        user&.moderator?
    end

    class Scope < BasePolicy::Scope
        def resolve
            scope.all
        end
    end
end
