class Team < ApplicationRecord
  # If your app uses Devise/User, this keeps the association
  # but makes it optional so the AC1 system spec can create a team
  # without signing in.
  belongs_to :user, optional: true if defined?(User)

  STATUSES     = %w[draft published].freeze
  VISIBILITIES = %w[private public].freeze

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true
  validates :visibility, inclusion: { in: VISIBILITIES }, allow_nil: true

  before_validation :set_defaults

  private

  def set_defaults
    self.status     ||= "draft"
    self.visibility ||= "private"
  end
end
