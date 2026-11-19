module Api
  module V1
    module Employee
      class AttendanceExceptionsController < Api::V1::BaseController
        # GET /api/v1/attendance_exceptions
        def index
          run AttendanceExceptions::Index, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # GET /api/v1/attendance_exceptions/:id
        def show
          run AttendanceExceptions::Show, id: params[:id], current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # POST /api/v1/attendance_exceptions/create_leave
        def create_leave
          run AttendanceExceptions::CreateLeave, params: leave_params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # POST /api/v1/attendance_exceptions/create_regularization
        def create_regularization
          run AttendanceExceptions::CreateRegularization, params: regularization_params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # PUT /api/v1/attendance_exceptions/:id/update_leave_days
        def update_leave_days
          run AttendanceExceptions::UpdateLeaveDays, params: params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        def update_regularization
          run AttendanceExceptions::UpdateRegularization, attendance_exception_id: params[:id], params: regularization_update_params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # DELETE /api/v1/attendance_exceptions/:id/withdraw_leave
        def withdraw_leave
          run AttendanceExceptions::WithdrawLeave, params: params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # DELETE /api/v1/attendance_exceptions/:id/withdraw_regularization
        def withdraw_regularization
          run AttendanceExceptions::WithdrawRegularization, params: params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        private

        def attendance_fields
          [
            :attendance_exception_id,
            :employee_id,
            :start_date,
            :end_date,
            :reason,
            :request_type,
            :status
          ]
        end

        def regularization_update_params
          params.require(:attendance_exception).permit(
            :status,
            :admin_reason
          )
        end

        def regularization_params
          params.require(:attendance_exception).permit(
            :start_date,
            :reason,
            :checkin_time,
            :checkout_time
          )
        end
        def leave_params
          params.require(:attendance_exception).permit(
            :employee_id,
            :start_date,
            :end_date,
            :reason
          )
        end
      end
    end
  end
end
