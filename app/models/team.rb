class Team < ApplicationRecord
  belongs_to :user
  has_many :favorites, as: :favoritable, dependent: :destroy

  validates :title, presence: true

  def owner
    user
  end

  def public?
    self[:public]
  end
end
