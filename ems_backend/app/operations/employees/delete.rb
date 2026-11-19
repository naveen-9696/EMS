
# frozen_string_literal: true

module Employees
  class Delete < Trailblazer::Operation
    step :authorize_delete
    step :find_employee
    step :delete_employee
    step :success_response

    fail :collect_errors

    def authorize_delete(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::EmployeeDetail,
        :destroy?
      )
    end

    def find_employee(ctx, id:, **)
      employee = EmployeeDetail.find_by(id: id)

      unless employee
        ctx[:errors] = [ "Employee details not found" ]
        return false
      end

      ctx[:employee] = employee
      true
    end

    def delete_employee(ctx, **)
      employee = ctx[:employee]

      if employee.destroy
        true
      else
        ctx[:errors] = employee.errors.full_messages
        false
      end
    end
    def success_response(ctx, **)
      ctx[:response] = {
          message: "Employee details deleted successfully"
        }
        ctx[:status] = :ok
    end
    def collect_errors(ctx, **)
      ctx[:error] = {
        msg: ctx[:errors] || [ "Employee deletion failed" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
