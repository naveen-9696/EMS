
class EmployeeDetail < ApplicationRecord
  belongs_to :user
  belongs_to :department

  has_many :attendance_records, dependent: :destroy
  has_many :attendance_exceptions, dependent: :destroy
  has_many :salary_records, dependent: :destroy

  validates :user_id, uniqueness: true

  validates :base_salary,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :designation,
            presence: true,
            inclusion: {
              in: [
                "Junior Software Engineer",
                "Software Engineer",
                "Senior Software Engineer",
                "Full Stack Developer",
                "DevOps Engineer"
              ]
            }
end
