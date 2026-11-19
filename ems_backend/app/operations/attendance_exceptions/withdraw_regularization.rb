
# frozen_string_literal: true

module AttendanceExceptions
  class WithdrawRegularization < Trailblazer::Operation
    step :authorize
    step :find_request
    step :withdraw
    step :success_response
    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ::AttendanceException, :withdraw_regularization?)
    end

    # STEP 1: Find the regularization request of the logged-in employee.
    def find_request(ctx, params:, current_user:, **)
      employee_detail = current_user&.employee_detail

      unless employee_detail
        ctx[:errors] = [ "Employee details not found" ]
        return false
      end

      request = employee_detail.attendance_exceptions.find_by(
        id: params[:id],
        request_type: "regularization"
      )

      unless request
        ctx[:errors] = [ "Regularization request not found" ]
        return false
      end

      ctx[:request] = request
      true
    end

    # STEP 2: Withdraw only pending regularization requests.
    def withdraw(ctx, **)
      request = ctx[:request]

      unless request.status == "pending"
        ctx[:errors] = [
          "Only pending regularization requests can be withdrawn"
        ]
        return false
      end

      unless request.destroy
        ctx[:errors] = request.errors.full_messages
        return false
      end

      true
    end

    # STEP 3: Prepare the error response.
    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Regularization withdrawal failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end

    def success_response(ctx, **)
      ctx[:response] = { message: "Regularization withdrawn successfully" }
      ctx[:status] = :ok
      true
    end
  end
end
