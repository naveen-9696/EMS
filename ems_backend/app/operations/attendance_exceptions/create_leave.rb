
module AttendanceExceptions
  class CreateLeave < Trailblazer::Operation
    step :authorize
    step :build_params
    step :check_existing_leave
    step :create_request
    step :success_response

    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::AttendanceException,
        :create_leave?
      )
      true
    end

    def build_params(ctx, current_user:, params:, **)
      employee_detail = if current_user&.role&.name.to_s.downcase == "admin" &&
          params[:employee_id].present?
        EmployeeDetail.find_by(id: params[:employee_id])
      else
        current_user&.employee_detail
      end

      unless employee_detail
        ctx[:errors] = [ "Employee details not found for the selected employee" ]
        return false
      end

      start_date = Date.iso8601(params[:start_date].to_s)
      end_date = Date.iso8601(params[:end_date].to_s)

      if start_date < Date.current
        ctx[:errors] = [ "You cannot apply leave for past dates" ]
        return false
      end

      if end_date < start_date
        ctx[:errors] = [ "End date cannot be before start date" ]
        return false
      end

      if params[:reason].blank?
        ctx[:errors] = [ "Reason is required" ]
        return false
      end

      leave_dates = WorkingDaysCalculator.working_dates(
        start_date,
        end_date
      )

      if leave_dates.empty?
        ctx[:errors] = [ "Selected date range contains no working days" ]
        return false
      end

      ctx[:employee_detail] = employee_detail
      ctx[:leave_dates] = leave_dates
      status = if current_user&.role&.name.to_s.downcase == "admin" &&
          employee_detail.user_id == current_user.id
        "approved"
      else
        "pending"
      end

      ctx[:attendance_exception_params] = {
        employee_detail_id: employee_detail.id,
        start_date: start_date,
        end_date: end_date,
        reason: params[:reason],
        request_type: "leave",
        status: status
      }

      true
    rescue Date::Error, TypeError
      ctx[:errors] = [ "Please provide valid start and end dates" ]
      false
    end

    def check_existing_leave(ctx, **)
      existing_dates = AttendanceExceptionDay
        .joins(:attendance_exception)
        .where(
          attendance_exceptions: {
            employee_detail_id: ctx[:employee_detail].id,
            request_type: "leave"
          },
          leave_date: ctx[:leave_dates]
        )
        .where.not(attendance_exceptions: { status: "rejected" })
        .where.not(attendance_exception_days: { status: "rejected" })
        .distinct
        .pluck(:leave_date)

      unless existing_dates.empty?
        formatted_dates = existing_dates.sort.map do |date|
          date.strftime("%d-%m-%Y")
        end

        ctx[:errors] = [
          "You already have leave requests for these dates: #{formatted_dates.join(', ')}"
        ]
        return false
      end

      true
    end

    def create_request(ctx, **)
      success = false

      AttendanceException.transaction do
        request = AttendanceException.new(
          ctx[:attendance_exception_params]
        )

        unless request.save
          ctx[:errors] = request.errors.full_messages
          raise ActiveRecord::Rollback
        end

        ctx[:leave_dates].each do |date|
          leave_day = request.attendance_exception_days.build(
            leave_date: date,
            status: request.status,
            leave_type: nil
          )

          unless leave_day.save
            ctx[:errors] = leave_day.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end

        ctx[:attendance_exception] = request
        success = true
      end

      success
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Leave created successfully",
        data: ctx[:attendance_exception]
      }
      ctx[:status] = :created
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Leave creation failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
