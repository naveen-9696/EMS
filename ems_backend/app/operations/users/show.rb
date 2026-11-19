module Users
  class Show < Trailblazer::Operation
    step :authorize
    step :find_user
    fail :collect_errors
    step :prepare_response

    def authorize(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::User,
        :show?
      )
    end
    def find_user(ctx, params:, **)
      user = User.find_by(id: params[:id])

      unless user
        ctx[:errors] = [ "User not found" ]
        return false
      end

      ctx[:user] = user
      true
    end

    def prepare_response(ctx, **)
      user = ctx[:user]

      ctx[:response] = {
        id: user.id,
        name: user.name,
        email: user.email,
        phase: user.phase,
        status: user.status,
        role: user.role&.name
      }
      ctx[:status] = :ok
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Failed to fetch bus operator",
        errors: ctx[:user]&.errors&.full_messages || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
