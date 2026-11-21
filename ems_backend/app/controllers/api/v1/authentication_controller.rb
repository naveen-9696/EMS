module Api
  module V1
    class AuthenticationController < Devise::SessionsController
      skip_before_action :verify_signed_out_user, only: [ :destroy ]
      before_action :authenticate_user!, only: [ :destroy ]
      skip_before_action :authenticate_user!, only: [ :signup ]

      respond_to :json

      # POST /api/v1/signup
      def signup
        result = run Users::Create, params: signup_params

        if result.success?
          render json: {
            message: "User registered successfully",
            data: result[:response_data]
          }, status: :created
        else
          render json: {
            errors: result[:errors]
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/login
      def create
        self.resource = warden.authenticate!(auth_options)

        result = run Authentication::Login, user: resource

        unless result.success?
          return render json: {
            error: result[:error][:msg]
          }, status: result[:error][:code]
        end

        sign_in(resource_name, resource)

        render json: {
          message: "Login successful",
          user: resource.as_json(only: [ :id, :name, :email, :phase, :status ]).merge(
            role_name: resource.role&.name
          ),
          login_at: result[:login_time]
        }, status: :ok
      end

      # DELETE /api/v1/logout
      def destroy
          puts "Current User: #{current_user.inspect}"
          puts "User Signed In: #{user_signed_in?}"
        result = run Authentication::Logout, current_user: current_user

        unless result.success?
          return render json: {
            error: result[:error][:msg]
          }, status: result[:error][:code]
        end

        sign_out(resource_name)

        render json: {
          message: "Logout successful",
          logout_at: result[:logout_time]
        }, status: :ok
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
    end
  end
end
