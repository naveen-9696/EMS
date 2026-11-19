module Authentication
  class Login < Trailblazer::Operation
    step :set_login_time
    step :mark_attendance

    fail :collect_errors

    def set_login_time(ctx, **)
      login_time = Time.current

      ctx[:login_time] = login_time

      ctx[:formatted_login_time] =
        login_time.in_time_zone("Asia/Kolkata")
                 .strftime("%d-%m-%Y %I:%M:%S %p")

      true
    end

    def mark_attendance(ctx, login_time:, user:, **)
      employee_detail = user.employee_detail

      # Admin users may not have employee details.
      return true unless employee_detail

      today_attendance = employee_detail.attendance_records
        .where(checkin_time: Date.current.all_day)
        .order(:checkin_time)
        .first

      if today_attendance
        # Reopen today's record after a previous logout. Keep the original
        # check-in; the next logout will replace the checkout time.
        return true if today_attendance.checkout_time.nil?

        if today_attendance.update(checkout_time: nil)
          return true
        end

        ctx[:errors] = today_attendance.errors.full_messages
        return false
      end

      attendance = employee_detail.attendance_records.new(
        checkin_time: login_time
      )

      if attendance.save
        true
      else
        ctx[:errors] = attendance.errors.full_messages
        false
      end
    end

    def collect_errors(ctx, **)
      ctx[:error] = {
        msg: ctx[:errors] || [ "Login attendance failed" ],
        code: 422
      }
    end
  end
end
