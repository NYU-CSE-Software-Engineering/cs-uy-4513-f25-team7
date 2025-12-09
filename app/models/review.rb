# app/models/review.rb
class Review < ApplicationRecord
  # Note: We don't use counter_cache because we need to exclude soft-deleted reviews
  belongs_to :team
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :body, length: { maximum: 500 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :team_id, message: "has already reviewed this team" }
  validate :cannot_review_own_team

  scope :visible, -> { where(deleted_at: nil) }
  scope :by_recent, -> { order(created_at: :desc) }

  after_save :update_team_average_rating
  after_destroy :update_team_average_rating

  def soft_delete!
    update!(deleted_at: Time.current)
    update_team_average_rating
  end

  def deleted?
    deleted_at.present?
  end

  private

  def cannot_review_own_team
    return unless team && user

    if team.user_id == user_id
      errors.add(:base, "You cannot review your own team")
    end
  end

  def update_team_average_rating
    team.recalculate_rating!
  end
end

