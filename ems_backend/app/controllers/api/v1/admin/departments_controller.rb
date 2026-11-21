module Api
  module V1
    module Admin
      class DepartmentsController < Api::V1::BaseController
        def index
          Pundit.authorize(current_user, Department, :index?)
          departments = Pundit.policy_scope!(current_user, Department)
            .order(:department_name)
            .select(:id, :department_name)

          render json: { data: departments.as_json(only: [ :id, :department_name ]) }, status: :ok
        end
      end
    end
  end
end
