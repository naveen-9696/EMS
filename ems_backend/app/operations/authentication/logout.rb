
module Authentication
  class Logout < Trailblazer::Operation
    step :set_logout_time
    step :validate_user
    step :mark_logout

    fail :collect_errors

    def set_logout_time(ctx, **)
      logout_time = Time.current

      ctx[:logout_time] = logout_time

      ctx[:formatted_logout_time] =
        logout_time.in_time_zone("Asia/Kolkata")
                  .strftime("%d-%m-%Y %I:%M:%S %p")

      true
    end

    def validate_user(ctx, current_user:, **)
      if current_user.nil?
        ctx[:errors] = ["User is not authenticated"]
        return false
      end

      true
    end

    def mark_logout(ctx, current_user:, logout_time:, **)
      employee_detail = current_user.employee_detail

      # Admin users may not have employee details.
      return true unless employee_detail

      attendance = employee_detail.attendance_records
        .where(checkin_time: Date.current.all_day)
        .order(checkin_time: :desc)
        .first

      unless attendance
        ctx[:errors] = ["No login attendance found for today"]
        return false
      end

      if attendance.checkout_time.present?
        ctx[:errors] = ["You are already logged out"]
        return false
      end

      if attendance.update(checkout_time: logout_time)
        true
      else
        ctx[:errors] = attendance.errors.full_messages
        false
      end
    end

    def collect_errors(ctx, **)
      ctx[:error] = {
        msg: ctx[:errors] || ["Logout failed"],
        code: 422
      }
    end
  end
end
