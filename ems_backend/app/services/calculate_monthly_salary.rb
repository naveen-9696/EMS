module CalculateMonthlySalary
  def calculate_month_salary(employee_detail, start_date, end_date)
    working_dates = WorkingDaysCalculator.working_dates(start_date, end_date)
    return nil if working_dates.empty?

    attendance_dates = employee_detail.attendance_records
      .where(checkin_time: start_date.beginning_of_day..end_date.end_of_day)
      .where.not(checkin_time: nil)
      .pluck(:checkin_time)
      .map(&:to_date)
      .uniq

    leave_days = AttendanceExceptionDay
      .joins(:attendance_exception)
      .where(
        attendance_exceptions: {
          employee_detail_id: employee_detail.id,
          request_type: "leave",
          status: "approved"
        },
        status: "approved",
        leave_date: start_date..end_date
      )
      .pluck(:leave_date, :leave_type)

    paid_leave_dates = leave_days
      .select { |_date, type| type == "paid" }
      .map { |date, _type| date.to_date }
      .uniq

    unpaid_leave_dates = leave_days
      .select { |_date, type| type == "unpaid" }
      .map { |date, _type| date.to_date }
      .uniq

    attendance_dates &= working_dates
    paid_leave_dates &= working_dates
    unpaid_leave_dates &= working_dates

    attendance_dates -= (paid_leave_dates + unpaid_leave_dates)

    recorded_dates = attendance_dates + paid_leave_dates + unpaid_leave_dates
    absent_days = (working_dates - recorded_dates).count

    present_days = attendance_dates.count
    paid_leave_days = paid_leave_dates.count
    approved_leave_days = paid_leave_days + unpaid_leave_dates.count

    base_salary = employee_detail.base_salary.to_d
    per_day_salary = base_salary / working_dates.count.to_d
    deduction = per_day_salary * (unpaid_leave_dates.count + absent_days)

    {
      base_salary: base_salary,
      present_days: present_days,
      approved_leave_days: approved_leave_days,
      paid_leave_days: paid_leave_days,
      payable_salary: (base_salary - deduction).round(2)
    }
  end
end
