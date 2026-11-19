module Attendances
  class Show < Trailblazer::Operation
    step :authorize
    step :find_attendance_record
    step :success_response
    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user,
      ::AttendanceRecord,
      :show?)
    end
    def find_attendance_record(ctx, id:, **)
      # binding.pry
      attendance_record = AttendanceRecord.find_by(id: id)

      unless attendance_record
        ctx[:errors] = [ "Attendance record not found" ]
        return false
      end

      ctx[:attendance_record] = attendance_record
      true
    end

    def success_response(ctx, **)
      ctx[:response] = ctx[:attendance_record]
      ctx[:status] = :ok
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        msg: ctx[:errors] || [ "Unable to fetch attendance record" ],
        code: 404
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
