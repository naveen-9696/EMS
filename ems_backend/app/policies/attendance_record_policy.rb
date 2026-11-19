
class AttendanceRecordPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      role = user&.role&.name.to_s.downcase

      case role
      when "admin"
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
    admin? || hr?
  end

  def create?
    admin? || hr?
  end

  def update?
    admin? || hr?
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
