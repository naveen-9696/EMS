# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SalaryRecordsController < Api::V1::BaseController
        # POST /api/v1/salary_records
        def create
          run SalaryRecords::Create, params: salary_params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # GET /api/v1/salary_records
        def index
          run SalaryRecords::Index, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # GET /api/v1/salary_records/:id
        def show
          run SalaryRecords::Show, params: { id: params[:id] }, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        private

        def salary_params
          params.permit(:month, :year).merge(
            employee_id: params[:employee_id]
          )
        end

        def filter_params
          params.permit(:month, :year)
        end
      end
    end
  end
end
