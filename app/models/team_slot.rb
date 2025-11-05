# app/models/team_slot.rb
class TeamSlot < ApplicationRecord
  belongs_to :team, inverse_of: :team_slots
  has_many :move_slots, dependent: :destroy

  accepts_nested_attributes_for :move_slots, allow_destroy: true, reject_if: :all_blank

  enum tera_type: {
    normal: 0, fire: 1, water: 2, electric: 3, grass: 4, ice: 5,
    fighting: 6, poison: 7, ground: 8, flying: 9, psychic: 10,
    bug: 11, rock: 12, ghost: 13, dragon: 14, dark: 15, steel: 16, fairy: 17
  }, _prefix: :tera

  # -------- NEW: virtual attribute + resolver --------
  # Allows the form to submit a species "name" alongside species_id.
  # If species_id is blank but species_name is present, we look it up.
  attr_accessor :species_name

  before_validation :resolve_species_from_name

  def resolve_species_from_name
    return if species_id.present?

    name = species_name.to_s.strip
    return if name.blank?

    # case-insensitive exact match against DexSpecies.name
    match = DexSpecies.find_by('LOWER(name) = ?', name.downcase)
    self.species_id = match.id if match
  end
  # ---------------------------------------------------

  # validations only if slot is actually used
  with_options if: -> { species_id.present? } do
    validates :species_id, presence: true
    # (add EV/IV validations here later if needed)
  end
end
