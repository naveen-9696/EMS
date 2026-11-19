
class Department < ApplicationRecord
  has_many :employee_details, dependent: :restrict_with_error

  validates :department_name,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :department_budget,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
end
