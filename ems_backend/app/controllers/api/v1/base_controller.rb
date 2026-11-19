
module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: "You are not authorized to perform this action" }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do |error|
        render json: { error: "Not Found", message: error.message }, status: :not_found
      end
    end
  end
end
