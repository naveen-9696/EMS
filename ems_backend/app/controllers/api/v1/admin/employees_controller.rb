# frozen_string_literal: true

module Api
  module V1
    module Admin
      class EmployeesController < Api::V1::BaseController
        # before_action -> { authorize_roles!("Admin", "HR") }

        def index
          run Employees::Index, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # GET /api/v1/employees/:id
        def show
          run Employees::Show, params: params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # POST /api/v1/employees
        def create
          run Employees::Create, params: employee_fields, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # PATCH /api/v1/employees/:id
        def update
          run Employees::Update, id: params[:id], params: employee_update_params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # DELETE /api/v1/employees/:id
        def destroy
          run Employees::Delete, id: params[:id], current_user: current_user
          render json: result[:response], status: result[:status]
        end

        private

        def employee_fields
          params.require(:employee).permit(
            :user_id,
            :department_id,
            :designation,
            :base_salary,
            :role_id
          )
        end

        def employee_update_params
          params.require(:employee).permit(
            :employee_id,
            :department_id,
            :designation,
            :role_id,
            :base_salary
          )
        end
      end
    end
  end
end
