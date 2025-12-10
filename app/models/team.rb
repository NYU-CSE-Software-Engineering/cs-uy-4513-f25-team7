class Team < ApplicationRecord
  belongs_to :user, optional: true
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :team_slots, -> { order(:slot_index) }, dependent: :destroy
  has_many :reviews, dependent: :destroy

  accepts_nested_attributes_for :team_slots, allow_destroy: true

  enum status: { draft: 0, published: 1 }

  # Avoid `private`/`public` enum values to prevent conflicts
  enum visibility: { private_team: 0, public_team: 1 }

  validates :name, presence: true
  validate  :max_six_slots

  before_save :touch_last_saved_at

  def max_six_slots
    if team_slots.reject(&:marked_for_destruction?).size > 6
      errors.add(:base, "A team can have at most 6 Pokémon")
    end
  end

  def touch_last_saved_at
    self.last_saved_at = Time.current
  end

  def any_illegal_slots?
    team_slots.any?(&:illegal?)
  end

  # Mark legality on the in-memory team + slots.
  # DOES NOT call save! – caller is responsible for persistence.
  def mark_legality!(version_groups: nil)
    any_illegal = false

    team_slots.each do |slot|
      illegals = Dex::LearnsetChecker.illegal_moves_for_slot(slot, version_groups: version_groups)

      if illegals.any?
        slot.illegal         = true
        slot.illegal_reasons = "Move cannot be learned: #{illegals.join(', ')}"
        any_illegal          = true
      else
        slot.illegal         = false
        slot.illegal_reasons = nil
      end
    end

    self.legal = !any_illegal
    self
  end

  # Human-facing visibility text for views / Cucumber expectations
  def visibility_label
    public_team? ? "Public" : "Private"
  end

  def owner
    user
  end

  # Recalculate the cached average rating from visible reviews
  def recalculate_rating!
    visible_reviews = reviews.visible
    self.reviews_count = visible_reviews.count
    self.average_rating = visible_reviews.average(:rating)&.round(2) || 0.0
    save!
  end

  # Scope for browsing highest-rated teams (requires minimum reviews)
  scope :highest_rated, ->(min_reviews: 2) {
    where("reviews_count >= ?", min_reviews).order(average_rating: :desc)
  }
end
