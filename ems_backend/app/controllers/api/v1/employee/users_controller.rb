module Api
  module V1
    module Employee
      class UsersController < Api::V1::BaseController
        skip_before_action :authenticate_user!, only: [ :create ]
        before_action :authenticate_user!, only: [ :update ]

        # GET /api/v1/users
        def index
          run Users::Index, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        # GET /api/v1/users/:id
        def show
          run Users::Show, current_user: current_user, params: params
          render json: result[:response], status: result[:status]
        end

        # POST /api/v1/users
        def create
         run Users::Create, params: signup_params
         render json: result[:response], status: result[:status]
        end

        # PUT /api/v1/users/:id
        def update
          run Users::Update, id: params[:id], params: user_params, current_user: current_user
          render json: result[:response], status: result[:status]
        end

        private

        def signup_params
          params.permit(
            :name,
            :email,
            :password,
            :password_confirmation
            )
        end

        def user_params
          params.require(:user).permit(
            :name,
            :email,
            :password,
            :password_confirmation,
            :phase,
            :status
          )
        end
      end
    end
  end
end
