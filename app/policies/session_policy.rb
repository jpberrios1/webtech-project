class SessionPolicy < BasePolicy
  def create?
    true # Cualquiera puede iniciar sesión
  end

  def destroy?
    true # Cualquiera puede cerrar sesión
  end
end