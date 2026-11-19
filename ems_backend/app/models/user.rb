class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  belongs_to :role
  has_one :employee_detail

  validates :name, presence: true

  validates :status,
            inclusion: { in: %w[active inactive] },
            allow_nil: true

  validates :phase,
            inclusion: { in: %w[new intern probation permanent resigned] },
            allow_nil: true

  def active_for_authentication?
    super &&
      status == "active" &&
      !%w[new resigned].include?(phase)
  end
end
