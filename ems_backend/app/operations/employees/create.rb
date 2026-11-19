module Employees
  class Create < Trailblazer::Operation
    step :authorize_create
    step :find_user
    step :check_existing_employee
    step :create_employee
    step :success_response

    fail :collect_errors

    def authorize_create(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::EmployeeDetail,
        :create?
      )
    end

    def find_user(ctx, params:, **)
      user = User.find_by(id: params[:user_id])

      unless user
        ctx[:errors] = [ "User not found" ]
        return false
      end

      ctx[:user] = user
      true
    end

    def check_existing_employee(ctx, **)
      if ctx[:user].employee_detail.present?
        ctx[:errors] = [ "An employee record already exists for this user" ]
        return false
      end
      true
    end

    def create_employee(ctx, params:, **)
      user = ctx[:user]

      ActiveRecord::Base.transaction do
        if params[:role_id].present?
          user.update!(role_id: params[:role_id])
        end

        employee = EmployeeDetail.create!(
          user_id: user.id,
          department_id: params[:department_id],
          designation: params[:designation],
          base_salary: params[:base_salary]
        )

        ctx[:employee] = employee
      end
      true
    rescue ActiveRecord::RecordInvalid => e
      ctx[:errors] = e.record.errors.full_messages
      false
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Employee details created successfully"
      }
      ctx[:status] = :ok
    end

    def collect_errors(ctx, **)
      error_code = ctx[:errors]&.include?("not found") ? 404 : 422

      ctx[:response] = {
        msg: ctx[:errors] || [ "Employee creation failed" ],
        code: error_code
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
