# app/models/team_slot.rb
class TeamSlot < ApplicationRecord
  belongs_to :team, inverse_of: :team_slots
  has_many :move_slots, dependent: :destroy

  accepts_nested_attributes_for :move_slots,
                                allow_destroy: true,
                                reject_if: :all_blank

  enum tera_type: {
    normal: 0, fire: 1, water: 2, electric: 3, grass: 4, ice: 5,
    fighting: 6, poison: 7, ground: 8, flying: 9, psychic: 10,
    bug: 11, rock: 12, ghost: 13, dragon: 14, dark: 15, steel: 16, fairy: 17
  }, _prefix: :tera

  # Only validate when the slot is actually used
  with_options if: -> { species_id.present? } do
    validates :species_id, presence: true
    validates :ev_hp,  :ev_atk, :ev_def, :ev_spa, :ev_spd, :ev_spe,
              numericality: { allow_nil: true, only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 252 }
    validates :iv_hp,  :iv_atk, :iv_def, :iv_spa, :iv_spd, :iv_spe,
              numericality: { allow_nil: true, only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 31 }
    # Add any “sum EVs ≤ 510” rule here, still guarded by species_id.present?
  end
end
