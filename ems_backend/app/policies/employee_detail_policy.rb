class EmployeeDetailPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      role = user&.role&.name.to_s.downcase

      case role
      when "admin", "hr"
        scope.all
      when "employee"
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end

  def index?
    admin? || hr? || employee?
  end

  def show?
    admin? || hr?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    user&.role&.name.to_s.downcase == "admin"
  end

  def hr?
    user&.role&.name.to_s.downcase == "hr"
  end

  def employee?
    user&.role&.name.to_s.downcase == "employee"
  end
end
