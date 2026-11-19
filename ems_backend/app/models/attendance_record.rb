
class AttendanceRecord < ApplicationRecord
  belongs_to :employee_detail

  validates :checkin_time, presence: true

  validate :checkout_after_checkin

  private

  def checkout_after_checkin
    return if checkin_time.blank? || checkout_time.blank?

    return unless checkout_time <= checkin_time
      errors.add(:checkout_time, "must be after check-in time")
  end
end
