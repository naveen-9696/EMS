module Attendances
  class Create < Trailblazer::Operation
    step :find_employee_detail
    step :mark_attendance
    fail :collect_errors

    def find_employee_detail(ctx, current_user:, **)
      employee_detail = current_user&.employee_detail

      unless employee_detail
        ctx[:errors] = [ "Employee details not found for this user" ]
        return false
      end

      ctx[:employee_detail] = employee_detail
      true
    end

    def mark_attendance(ctx, params:, **)
      attendance = ctx[:employee_detail].attendance_records.new(
        checkin_time: params[:checkin_time],
        checkout_time: params[:checkout_time]
      )

      if attendance.save
        ctx[:attendance] = attendance
        true
      else
        ctx[:errors] = attendance.errors.full_messages
        false
      end
    end

    def collect_errors(ctx, **)
      ctx[:error] = {
        msg: ctx[:errors] || [ "Unable to mark attendance" ],
        code: 422
      }
    end
  end
end
