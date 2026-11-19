
class AttendanceExceptionDay < ApplicationRecord
  belongs_to :attendance_exception

  validates :leave_date, presence: true

  validates :status,
            presence: true,
            inclusion: { in: %w[pending approved rejected] }

  validates :leave_date,
            uniqueness: {
              scope: :attendance_exception_id,
              message: "already exists for this request"
            }
end
