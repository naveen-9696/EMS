module Attendances
  class Index < Trailblazer::Operation
    step :authorize
    step :find_attendances
    step :success_response
    fail :collect_errors

    def authorize(ctx, current_user:, **)
      true
    end
    def find_attendances(ctx, current_user:, **)
      ctx[:attendance_records] = Pundit.policy_scope(current_user, ::AttendanceRecord)
      attendance_records = ctx[:attendance_records]

      unless attendance_records
        ctx[:errors] = [ "Attendance records were not provided" ]
        return false
      end

      ctx[:records] = attendance_records
      true
    end

    def success_response(ctx, **)
      ctx[:response] = ctx[:records].map do |attendance_record|
        {
          attendance_record: attendance_record.as_json(
            only: [
              :id,
              :employee_detail_id,
              :checkin_time,
              :checkout_time
            ]
          ),
          user: attendance_record&.employee_detail&.user&.as_json(
            only: [
              :id,
              :name
            ]
          )
        }
      end
      ctx[:status] = :ok
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        msg: ctx[:errors] || [ "Unable to fetch attendance records" ],
        code: 422
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
