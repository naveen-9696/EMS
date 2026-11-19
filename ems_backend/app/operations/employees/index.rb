module Employees
  class Index < Trailblazer::Operation
    step :authorize_index
    step :fetch_employees
    step :format_employee_data

    fail :collect_errors

    def authorize_index(ctx, current_user:, **)
      true
    end

    def fetch_employees(ctx, current_user:, **)
      ctx[:employee_records] = Pundit.policy_scope(
        current_user,
        ::EmployeeDetail
      )
      true
    rescue StandardError => e
      ctx[:errors] = [ "Error fetching employee details: #{e.message}" ]
      false
    end

    def format_employee_data(ctx, **)
      ctx[:response] = ctx[:employee_records].map do |employee_detail|
        {
          employee_detail: employee_detail.as_json(
            only: [
              :id,
              :user_id,
              :department_id,
              :designation,
              :base_salary
            ]
          ),
          user: employee_detail.user&.as_json(
            only: [
              :id,
              :name,
              :email,
              :status,
              :phase
            ]
          )
        }
      end

      ctx[:status] = :ok
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Fetching employee records failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }

      ctx[:status] = :unprocessable_entity
    end
  end
end
