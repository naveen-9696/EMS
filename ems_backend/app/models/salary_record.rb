
class SalaryRecord < ApplicationRecord
  belongs_to :employee_detail

  validates :month,
            presence: true,
            inclusion: { in: 1..12 }

  validates :year,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :payable_salary,
            :base_salary,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :present_days,
            :approved_leave_days,
            :paid_leave_days,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :month,
            uniqueness: {
              scope: [ :employee_detail_id, :year ],
              message: "salary record already exists for this month"
            }
end
