class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_error

  ROLES = %w[Admin HR Employee].freeze

  validates :name,
            presence: true,
            inclusion: { in: ROLES },
            uniqueness: { case_sensitive: false }
end
