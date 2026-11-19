
# frozen_string_literal: true

module AttendanceExceptions
  class CreateRegularization < Trailblazer::Operation
    step :authorize
    step :build_params
    step :check_existing_request
    step :create_request
    step :success_response

    fail :collect_errors
    def authorize(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::AttendanceException,
        :create_regularization?
      )
    end
    # STEP 1: Prepare and validate the regularization details.
    def build_params(ctx, params:, current_user:, **)
      employee_detail = current_user&.employee_detail

      unless employee_detail
        ctx[:errors] = [ "Employee details not found" ]
        return false
      end

      permitted_params = params.permit(
        :start_date,
        :reason,
        :checkin_time,
        :checkout_time
      )

      begin
        entered_date = Date.iso8601(
          permitted_params[:start_date].to_s
        )
      rescue Date::Error, TypeError
        ctx[:errors] = [ "Please provide a valid regularization date" ]
        return false
      end

      if entered_date > Date.current
        ctx[:errors] = [ "You cannot apply regularization for future dates" ]
        return false
      end
      if entered_date.wday == 0
        ctx[:errors] = [ "you cannot apply regularization for sunday" ]
        return false
      end
      if entered_date < 3.months.ago.to_date
        ctx[:errors] = [ "You cannot apply regularization for more than 3 months older dates" ]
        return false
      end

      ctx[:attendance_exception_params] = {
        employee_detail_id: employee_detail.id,
        start_date: entered_date,
        end_date: entered_date,
        reason: permitted_params[:reason],
        checkin_time: permitted_params[:checkin_time],
        checkout_time: permitted_params[:checkout_time],
        request_type: "regularization",
        status: "pending"
      }

      true
    end

    #  Check whether a non-rejected request already exists.
    def check_existing_request(ctx, **)
      request_params = ctx[:attendance_exception_params]

      existing_request = AttendanceException.where(
        employee_detail_id: request_params[:employee_detail_id],
        start_date: request_params[:start_date],
        request_type: "regularization"
      ).where.not(status: "rejected").exists?

      if existing_request
        ctx[:errors] = [
          "You already have a pending or approved regularization request for this date"
        ]
        return false
      end

      true
    end

    # STEP 3: Save the regularization request.
    def create_request(ctx, **)
      request = AttendanceException.new(
        ctx[:attendance_exception_params]
      )

      if request.save
        ctx[:attendance_exception] = request
        true
      else
        ctx[:errors] = request.errors.full_messages
        false
      end
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Regularization created successfully",
        data: ctx[:attendance_exception]
      }
      ctx[:status] = :created
      true
    end

    # STEP 4: Prepare the error response.
    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Regularization creation failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
