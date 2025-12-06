class DexLearnset < ApplicationRecord
  belongs_to :dex_species
  belongs_to :dex_move

  validates :method, presence: true
end
