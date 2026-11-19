
module AttendanceExceptions
  class UpdateLeaveDays < Trailblazer::Operation
    step :authorize
    step :find_request
    step :update_leave_days_and_request_status
    step :success_response

    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ::AttendanceException, :update_leave_days?)
    end

    def find_request(ctx, params:, **)
      ctx[:request] = AttendanceException.find_by(
        id: params[:id],
        request_type: "leave"
      )

      if ctx[:request].nil?
        ctx[:errors] = [ "Leave request not found" ]
        return false
      end

      true
    end

    def success_response(ctx, **)
      ctx[:response] = { message: "Leave days updated successfully" }
      ctx[:status] = :ok
      true
    end

    def update_leave_days_and_request_status(ctx, params:, **)
      request = ctx[:request]
      employee_detail = request.employee_detail

      permitted_params = params.permit(
        days: [ :leave_date, :status, :admin_reason ]
      )

      days = permitted_params[:days]

      if days.blank?
        ctx[:errors] = [ "Please provide leave days to update" ]
        return false
      end

      success = false

      AttendanceException.transaction do
        days.each do |day_params|
          date = Date.iso8601(day_params[:leave_date].to_s)
          status = day_params[:status].to_s

          unless %w[approved rejected].include?(status)
            ctx[:errors] = [ "Invalid leave status" ]
            raise ActiveRecord::Rollback
          end

          leave_day = request.attendance_exception_days.find_by(
            leave_date: date
          )

          unless leave_day
            ctx[:errors] = [ "Leave day not found" ]
            raise ActiveRecord::Rollback
          end

          unless leave_day.status == "pending"
            ctx[:errors] = [ "Only pending leave days can be updated" ]
            raise ActiveRecord::Rollback
          end

          leave_type = nil

          if status == "approved"
            leave_type = LeaveBalanceCalculator.leave_type(
              employee_detail,
              date
            )
          end

          updated = leave_day.update(
            status: status,
            leave_type: leave_type,
            admin_reason: day_params[:admin_reason]
          )

          unless updated
            ctx[:errors] = leave_day.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end

        statuses = request.attendance_exception_days.pluck(:status)

        new_status =
          if statuses.all? { |status| status == "approved" }
            "approved"
          elsif statuses.all? { |status| status == "rejected" }
            "rejected"
          elsif statuses.all? { |status| status == "pending" }
            "pending"
          else
            "partially_approved"
          end

        unless request.update(status: new_status)
          ctx[:errors] = request.errors.full_messages
          raise ActiveRecord::Rollback
        end

        success = true
      end

      success

    rescue Date::Error, TypeError
      ctx[:errors] = [ "Invalid leave date" ]
      false
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Leave update failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
