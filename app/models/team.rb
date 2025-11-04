# app/models/team.rb
class Team < ApplicationRecord
  belongs_to :user
  belongs_to :format, optional: true

  has_many :team_slots, -> { order(:position) }, dependent: :destroy, inverse_of: :team
  has_many :legality_issues, dependent: :destroy

  enum status: { draft: 0, published: 1 }, _default: :draft
  enum visibility: { private_vis: 0, unlisted: 1, public_vis: 2 }, _prefix: :visibility

  # Option A (strongest): only persist a slot if it has a species selected
  accepts_nested_attributes_for :team_slots,
                                allow_destroy: true,
                                reject_if: ->(attrs) { attrs['species_id'].blank? }

  # -- OR --

  # Option B: treat a slot as blank if everything EXCEPT position/_destroy is blank
  # accepts_nested_attributes_for :team_slots,
  #   allow_destroy: true,
  #   reject_if: ->(attrs) { attrs.except('position', '_destroy').values.all?(&:blank?) }

  validate :max_six_slots
  def max_six_slots
    errors.add(:base, 'A team can have at most 6 Pokémon') if team_slots.reject(&:marked_for_destruction?).size > 6
  end

  def last_saved_label
    "Saved draft: #{name.presence || 'Untitled Team'}"
  end
end
