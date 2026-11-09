class ApplicationPolicy < BasePolicy

    def index?
        user.present?
    end

    def show?
        return false if user.nil?
        user.moderator? || record.seeker == user || record.listing.property.user == user
    end

    def create? 
        return false if user.nil?
        return true if record.is_a?(Class) || record.listing.nil?
        record.listing.property.user != user && record.listing.published?
    end

    def update?
        return flase if user.nil?
        record.listing.property.user == user
    end

    def shortlist?
        update?
    end

    def accept?
        update?
    end

    def reject?
        update?
    end

    #Only the seeker who wrote it while pending or shortlisted

    def withdraw?
        return false if user.nil?
        record.seeker == user && (record.pending? || record.shortlisted?)
    end

    def destroy?
        withdraw?
    end

    class Scope < BasePolicy::Scope
        def resolve
            return scope.none if user.nil?
            return scope.all if user.moderator?

            scope.joins(listing: :property).where("applications.seeker_id = :uid OR properties.user_id = :uid",
                                                  uid: user.id).distinct
        end
    end
end