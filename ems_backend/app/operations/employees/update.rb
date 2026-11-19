module Employees
  class Update < Trailblazer::Operation
    step :authorize_update
    step :find_employee
    step :update_employee
    step :success_response

    fail :collect_errors

    def authorize_update(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::EmployeeDetail,
        :update?
      )
    end

    def find_employee(ctx, id:, **)
      employee = EmployeeDetail.find_by(id: id)

      unless employee
        ctx[:errors] = [ "Employee  not found" ]
        return false
      end

      ctx[:employee] = employee
      true
    end

    def update_employee(ctx, params:, **)
      employee = ctx[:employee]

      ActiveRecord::Base.transaction do
        employee.update!(
          params.slice(
            :department_id,
            :designation,
            :base_salary
          )
        )
      end

      true
    rescue ActiveRecord::RecordInvalid => e
      ctx[:errors] = e.record.errors.full_messages
      false
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Employee details updated successfully",
        data: ctx[:employee].as_json(
          only: [
            :id,
            :user_id,
            :department_id,
            :designation,
            :base_salary
          ]
        )
      }
      ctx[:status] = :ok
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Unable to update employee details",
        errors: ctx[:errors] || [ "Unknown error" ]
      }

      ctx[:status] = :unprocessable_entity
    end
  end
end
