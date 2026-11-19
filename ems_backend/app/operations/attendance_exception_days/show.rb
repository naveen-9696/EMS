
# frozen_string_literal: true

module AttendanceExceptionDays
  class Show < Trailblazer::Operation
    step :find_exception_days
    step :success_response

    fail :collect_errors

    def find_exception_days(ctx, params:, current_user:, **)
      unless current_user
        ctx[:errors] = [ "User not authenticated" ]
        return false
      end

      exception = AttendanceException.find_by(
        id: params[:id],
        request_type: "leave"
      )

      unless exception
        ctx[:errors] = [ "Leave request not found" ]
        return false
      end

      exception_days = Pundit.policy_scope!(
        current_user,
        AttendanceExceptionDay.includes(
          attendance_exception: :employee_detail
        )
      ).where(attendance_exception_id: exception.id)

      ctx[:exception_days] = exception_days

      true
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Attendance exception days fetched successfully",
        data: ctx[:exception_days]
      }
      ctx[:status] = :ok
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Failed to fetch attendance exception days",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :not_found
    end
  end
end
