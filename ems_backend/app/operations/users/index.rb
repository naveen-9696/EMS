module Users
  class Index < Trailblazer::Operation
    step :authorize
    step :find_users
    fail :handle_failure
    step :success_response

    def authorize(ctx, current_user:, **)
      true
    end

    def find_users(ctx, current_user:, **)
      ctx[:users] = Pundit.policy_scope(current_user, ::User)
      true
    rescue StandardError => e
      ctx[:error] = "Error fetching user records: #{e.message}"
      false
    end

    def handle_failure(ctx, **)
      ctx[:response] = {
        message: "Failed to fetch users",
        errors: [ ctx[:error] || "Unknown error" ]
      }

      ctx[:status] ||= :unprocessable_entity
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Users fetched successfully",
        data: ctx[:users]
      }

      ctx[:status] = :ok
    end
  end
end
