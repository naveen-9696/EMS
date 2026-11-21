module Attendances
  class Update < Trailblazer::Operation
    step :find_employee_detail
    step :find_attendance
    step :authorize_update
    step :update_attendance
    step :success_response
    fail :collect_errors

    def find_employee_detail(ctx, employee_detail_id:, **)
      # binding.pry
      employee_detail = EmployeeDetail.find_by(id: employee_detail_id)

      unless employee_detail
        ctx[:errors] = [ "Employee details not found" ]
        return false
      end

      ctx[:employee_detail] = employee_detail
      true
    end

    def find_attendance(ctx, id:, **)
      attendance = ctx[:employee_detail].attendance_records.find_by(
        id: id
      )

      unless attendance
        ctx[:errors] = [ "Attendance record not found for this employee" ]
        return false
      end

      ctx[:attendance] = attendance
      true
    end

    def update_attendance(ctx, params:, **)
      if ctx[:attendance].update(params)
        true
      else
        ctx[:errors] = ctx[:attendance].errors.full_messages
        false
      end
    end

    def authorize_update(ctx, current_user:, **)
      Pundit.authorize(current_user, ctx[:attendance], :update?)
    end

    def success_response(ctx, **)
      ctx[:response] = {
      message: "Attendance details updated successfully",
      data: ctx[:attendance]
    }
      ctx[:status] = :ok
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        msg: ctx[:errors] || [ "Unable to update attendance" ],
        code: 422
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
