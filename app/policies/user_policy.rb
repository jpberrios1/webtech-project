class UserPolicy < BasePolicy
  def show?
    true
  end

  def create?
    true 
  end

  def update?
    user.present? && record == user 
  end

  def destroy?
    user.present? && (record == user || user.moderator?)
  end

  class Scope < BasePolicy::Scope
    def resolve
      scope.all
    end
  end
end