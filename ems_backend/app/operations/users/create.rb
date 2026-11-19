
module Users
  class Create < Trailblazer::Operation
    step :create_user

    fail :collect_errors

    def create_user(ctx, params:, **)
      employee_role = Role.find_by(name: "Employee")

      unless employee_role
        ctx[:errors] = [ "Employee role not found. Please create it first." ]
        return false
      end

      user = User.new(
        name: params[:name],
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation].presence || params[:password],
        role_id: employee_role.id,
        phase: "new",
        status: "active"
      )

      ctx[:user] = user

      if user.save
        ctx[:response] = {
          message: "User signed up successfully"
        }

        ctx[:status] = :created
        true
      else
        ctx[:errors] = user.errors.full_messages
        false
      end
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Failed to signup user",
        errors: ctx[:errors] || [ "Unknown error" ]
      }

      ctx[:status] = :unprocessable_entity
    end
  end
end
