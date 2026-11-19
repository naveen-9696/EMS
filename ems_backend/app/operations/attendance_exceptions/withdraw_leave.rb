module AttendanceExceptions
  class WithdrawLeave < Trailblazer::Operation
    step :authorize
    step :find_request
    step :withdraw_request
    step :success_response

    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ::AttendanceException, :withdraw_leave?)
    end

    # STEP 1: Find the leave request belonging to the logged-in employee.
    def find_request(ctx, current_user:, params:, **)
      employee_detail = current_user&.employee_detail

      unless employee_detail
        ctx[:errors] = [ "Employee details not found" ]
        return false
      end

      request = employee_detail.attendance_exceptions.find_by(
        id: params[:id],
        request_type: "leave"
      )

      unless request
        ctx[:errors] = [ "Leave request not found" ]
        return false
      end

      ctx[:request] = request
      true
    end

    # STEP 2: Withdraw only pending leave requests.
    def withdraw_request(ctx, **)
      request = ctx[:request]

      unless request.status == "pending"
        ctx[:errors] = [
          "Only pending leave requests can be withdrawn"
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
        message: "Leave withdrawal failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end

    def success_response(ctx, **)
      ctx[:response] = { message: "Leave withdrawn successfully" }
      ctx[:status] = :ok
      true
    end
  end
end
