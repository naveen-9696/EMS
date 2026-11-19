
# frozen_string_literal: true

module AttendanceExceptionDays
  class Index < Trailblazer::Operation
    step :authorize
    step :fetch_exception_days
    step :success_response

    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ::AttendanceExceptionDay, :index?)
    end

    def fetch_exception_days(ctx, current_user:, **)
      unless current_user
        ctx[:errors] = [ "User not authenticated" ]
        return false
      end

      ctx[:exception_days] = Pundit.policy_scope!(
        current_user,
        ::AttendanceExceptionDay
      )

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
      ctx[:status] = :unprocessable_entity
    end
  end
end
