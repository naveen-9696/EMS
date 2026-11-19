
class AttendanceException < ApplicationRecord
  belongs_to :employee_detail

  has_many :attendance_exception_days,
           dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true

  validates :request_type,
            presence: true,
            inclusion: { in: %w[leave regularization] }

  validates :status,
            inclusion: { in: %w[pending approved rejected partially_approved] },
            allow_nil: true

  validate :end_date_after_start_date
  validate :validate_regularization_times

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    return unless end_date < start_date
      errors.add(:end_date, "must be on or after start date")
  end

  def validate_regularization_times
    return unless request_type == "regularization"

    errors.add(:checkin_time, "can't be blank") if checkin_time.blank?
    errors.add(:checkout_time, "can't be blank") if checkout_time.blank?

    return if checkin_time.blank? || checkout_time.blank?

    return unless checkout_time <= checkin_time
      errors.add(:checkout_time, "must be after check-in time")
  end
end
