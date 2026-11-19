
class SalaryRecordPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      role = user&.role&.name.to_s.downcase

      case role
      when "admin", "hr"
        scope.all

      when "employee"
        employee_detail = user.employee_detail

        if employee_detail
          scope.where(employee_detail_id: employee_detail.id)
        else
          scope.none
        end

      else
        scope.none
      end
    end
  end

  def index?
    admin? || hr? || employee?
  end

  def show?
    admin? || hr? || employee_owns_record?
  end

  def create?
    admin?
  end

  def destroy?
    admin?
  end

  def update?
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

  def employee_owns_record?
    return false unless employee?

    employee_detail = user.employee_detail
    return false unless employee_detail

    record.employee_detail_id == employee_detail.id
  end
end
