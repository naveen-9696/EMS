module AttendanceExceptions
  class Show < Trailblazer::Operation
    step :authorize
    step :find_attendance_exception
    step :success_response

    fail :collect_errors
    def authorize(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::AttendanceException,
        :show?
      )
    end
    def find_attendance_exception(ctx, id:, **)
      record = AttendanceException.find_by(id: id)
      unless record
        ctx[:errors] = [ "Attendance exception not found" ]
        return false
      end

      ctx[:attendance_exception] = record

      true
    end
    def success_response(ctx, **)
      ctx[:response] = {
        message: "Attendance exception fetched successfully",
        data: ctx[:attendance_exception]
      }
      ctx[:status] = :ok
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Failed to fetch attendance exception",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
