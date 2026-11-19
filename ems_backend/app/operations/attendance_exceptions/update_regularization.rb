
# frozen_string_literal: true

module AttendanceExceptions
  class UpdateRegularization < Trailblazer::Operation
    step :authorize
    step :find_request
    step :update_regularization
    step :success_response

    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ::AttendanceException, :update_regularization?)
    end

    # STEP 1: Find the regularization request.
    def find_request(ctx, attendance_exception_id:, **)
      request = AttendanceException.find_by(
        id: attendance_exception_id,
        request_type: "regularization"
      )

      unless request
        ctx[:errors] = [ "Regularization request not found" ]
        return false
      end

      ctx[:request] = request
      true
    end

    # STEP 2: Approve or reject the regularization request.
    def update_regularization(ctx, params:, **)
      request = ctx[:request]
      status = params[:status].to_s

      unless %w[approved rejected].include?(status)
        ctx[:errors] = [
          "Invalid status. Use approved or rejected"
        ]
        return false
      end

      already_approved = request.status == "approved" && status == "approved"

      unless request.status == "pending" || already_approved
        ctx[:errors] = [
          "This regularization request has already been processed"
        ]
        return false
      end

      success = false

      AttendanceException.transaction do
        # Update attendance for this date, creating it if none exists.
        if status == "approved"
          attendance = AttendanceRecord.where(
            employee_detail_id: request.employee_detail_id,
            checkin_time: request.start_date.all_day
          ).first_or_initialize

          attendance.checkin_time = request.start_date.in_time_zone.change(
            hour: request.checkin_time.hour,
            min: request.checkin_time.min,
            sec: request.checkin_time.sec
          )
          attendance.checkout_time = request.start_date.in_time_zone.change(
            hour: request.checkout_time.hour,
            min: request.checkout_time.min,
            sec: request.checkout_time.sec
          )

          unless attendance.save
            ctx[:errors] = attendance.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end

        # Update the regularization request status.
        unless request.status == status || request.update(status: status)
          ctx[:errors] = request.errors.full_messages
          raise ActiveRecord::Rollback
        end

        success = true
      end

      success
    end

    def success_response(ctx, **)
      ctx[:response] = { message: "Regularization updated successfully" }
      ctx[:status] = :ok
      true
    end

    # STEP 3: Prepare the error response.
    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Regularization update failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
