
module LeaveBalanceCalculator
  ANNUAL_PAID_LEAVE_LIMIT = 18

  def self.approved_paid_dates(employee_detail, year)
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)

    employee_detail.attendance_exceptions
      .where(request_type: "leave")
      .joins(:attendance_exception_days)
      .where(
        attendance_exception_days: {
          leave_date: start_date..end_date,
          status: "approved",
          leave_type: "paid"
        }
      )
      .distinct
      .pluck("attendance_exception_days.leave_date")
  end

  def self.paid_leaves_taken(employee_detail, year)
    approved_paid_dates(employee_detail, year).count
  end

  def self.remaining_paid_leaves(employee_detail, year)
    taken = paid_leaves_taken(employee_detail, year)

    [ ANNUAL_PAID_LEAVE_LIMIT - taken, 0 ].max
  end

  def self.leave_type(employee_detail, date)
    taken = paid_leaves_taken(employee_detail, date.year)

    if taken < ANNUAL_PAID_LEAVE_LIMIT
      "paid"
    else
      "unpaid"
    end
  end
end
