module Api
  module V1
    module Employee
      class AttendanceExceptionDaysController < Api::V1::BaseController
        def index
          run AttendanceExceptionDays::Index, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        def show
          run AttendanceExceptionDays::Show, params: { id: params[:id] }, current_user: current_user
          render json: result[:response], status: result[:status]
        end
      end
    end
  end
end
