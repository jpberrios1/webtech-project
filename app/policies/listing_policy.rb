class ListingPolicy < BasePolicy

    def index?
        true
    end

    def show?
        return true if record.published? || record.reserved? || record.rented?
        return false if user.nil?

        user.moderator? || record.property.user == user
    end

    def create?
        return false if user.nil?
        return true if record.is_a?(Class) || record.property.nil?

        user.moderator? || record.property.user == user
    end

    def update?
        return false if user.nil?

        user.moderator? || record.property.user == user
    end

    def destroy?
        update?
    end

    def publish?
        update?
    end

    def withdraw?
        update?
    end

    def mark_as_rented?
        update?
    end

    class Scope < BasePolicy::Scope
        def resolve 
            if user&.moderator?
                scope.all
            elsif user.present?
                scope.left_joins(:property).where( "listings.status IN (?) OR properties.user_id = ?",
                                                  ["published", "reserved", "rented"], user.id)
            else
                scope.where(status: ["published", "reserved", "rented"])
            end
        end
    end
end