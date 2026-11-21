
module AttendanceExceptions
  class Index < Trailblazer::Operation
    step :authorize
    step :find_all
    step :success_response

    fail :collect_errors

    def authorize(ctx, current_user:, **)
      true
    end

    def find_all(ctx, current_user:, **)
      attendance_exception_records =
        Pundit.policy_scope(current_user, ::AttendanceException)

      ctx[:attendance_exception_records] = attendance_exception_records
      true
    end

    def success_response(ctx, **)
      data = ctx[:attendance_exception_records].map do |attendance_exception|
        {
          attendance_exception: attendance_exception.as_json(
            only: [
              :id,
              :employee_detail_id,
              :start_date,
              :end_date,
              :reason,
              :request_type,
              :status,
              :checkin_time,
              :checkout_time
            ]
          ),
          leave_dates: attendance_exception.attendance_exception_days.where(status: "pending").order(:leave_date).pluck(:leave_date).map(&:iso8601),

          employee_detail: attendance_exception.employee_detail&.as_json(
            only: [
              :id,
              :user_id,
              :department_id,
              :designation,
              :base_salary
            ]
          ),

          user: attendance_exception.employee_detail&.user&.as_json(
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

      ctx[:response] = {
        message: "Attendance exceptions fetched successfully",
        data: data
      }

      ctx[:status] = :ok
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Failed to fetch attendance exceptions",
        errors: [ ctx[:error] || "Unknown error" ]
      }

      ctx[:status] = :unprocessable_entity
    end
  end
end
