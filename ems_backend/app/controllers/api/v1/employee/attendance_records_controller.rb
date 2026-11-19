module Api
  module V1
    module Employee
      class AttendanceRecordsController < Api::V1::BaseController
        def index
          run Attendances::Index, current_user: current_user
          render json: result[:response], status: result[:status]
        end
        # GET /api/v1/users/:id
        def show
          run Attendances::Show, id: params[:id], current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # POST /api/v1/attendance_records
        def create
          authorize ::AttendanceRecord, :create?

          result = run Attendances::Create, params: attendance_params do |res|
            return render json: { message: "Attedance marked Succesfully" }, status: :ok
          end
          render json: { data: result[:error][:msg] }, status: result[:error][:code]
        end
        # PUT /api/v1/employees/:id
        def update
          run Attendances::Update, employee_detail_id: params[:employee_id], id: params[:id], params: attendance_params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        private

        def attendance_params
          params.require(:attendance_record).permit(
            :checkin_time,
            :checkout_time
          )
        end
      end
    end
  end
end
