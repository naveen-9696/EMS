class DepartmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user&.role&.name.to_s.downcase == "admin"

      scope.none
    end
  end

  def index?
    user&.role&.name.to_s.downcase == "admin"
  end
end
