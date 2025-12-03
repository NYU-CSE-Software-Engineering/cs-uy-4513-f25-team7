class DexMove < ApplicationRecord
  has_many :dex_learnsets, dependent: :destroy
  has_many :dex_species, through: :dex_learnsets

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :by_name_ci, ->(name) { where("LOWER(name) = ?", name.to_s.downcase) }

  def self.find_by_name_ci(name)
    by_name_ci(name).first
  end
end
