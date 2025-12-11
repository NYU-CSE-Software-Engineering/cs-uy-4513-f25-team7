class SpeciesFollow < ApplicationRecord
  belongs_to :user
  belongs_to :dex_species

  validates :user_id, uniqueness: { scope: :dex_species_id }
end

