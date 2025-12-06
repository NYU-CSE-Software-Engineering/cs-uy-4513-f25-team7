class DexSpecies < ApplicationRecord
  has_many :dex_learnsets, dependent: :destroy
  has_many :dex_moves, through: :dex_learnsets
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Case-insensitive partial lookup for autocomplete/search
  scope :lookup_query, ->(q) do
    term = q.to_s.strip
    return none if term.blank?

    where("LOWER(name) LIKE ?", "%#{term.downcase}%").order(:name)
  end
end
