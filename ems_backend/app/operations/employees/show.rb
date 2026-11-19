
# frozen_string_literal: true

module Employees
  class Show < Trailblazer::Operation
    step :authorize
    step :find_employee
    step :success_response
    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::EmployeeDetail,
        :show?
      )
    end

    def find_employee(ctx, params:, **)
      # binding.pry
      employee = EmployeeDetail.find_by(id: params[:id])

      unless employee
        ctx[:errors] = [ "Employee details not found" ]
        return false
      end

      ctx[:employee] = employee
      true
    end

    def success_response(ctx, **)
      ctx[:response] = { data:  ctx[:employee] }
      ctx[:status] = :ok
    end
    def collect_errors(ctx, **)
      ctx[:response] = {
        msg: ctx[:errors] || [ "Unable to fetch employee" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
