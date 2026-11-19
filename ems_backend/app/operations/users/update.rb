module Users
  class Update < Trailblazer::Operation
    step :authorize_update
    step :find_user
    step :update_user

    fail :collect_errors

    def authorize_update(ctx, current_user:, **)
      Pundit.authorize(
        current_user,
        ::User,
        :update?
      )
    end

    def find_user(ctx, id:, **)
      user = User.find_by(id: id)

      unless user
        ctx[:errors] = [ "User not found" ]
        ctx[:status] = 404
        return false
      end

      ctx[:user] = user
      true
    end

    def update_user(ctx, params:, **)
      attributes = params.to_h.symbolize_keys.slice(
        :name,
        :email,
        :password,
        :password_confirmation,
        :role_id,
        :phase,
        :status
      )

      if attributes[:password].blank?
        attributes.delete(:password)
        attributes.delete(:password_confirmation)
      end

      if ctx[:user].update(attributes)
        ctx[:response] = {
          message: "User updatd successfully",
          data: {
            name: ctx[:user].name,
            email: ctx[:user].email,
            role_id: ctx[:user].role_id,
            phase: ctx[:user].phase,
            status: ctx[:user].status
          }
        }
        ctx[:status] = :ok
        true
      else
        ctx[:errorr] = ctx[:user].errors.full_messages
        false
      end
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: ctx[:errors] || [ "User update failed" ],
        errors: [ ctx[:error] || "Unknown error" ]
      }
      ctx[:status] ||= :unprocessable_entity
    end
  end
end
