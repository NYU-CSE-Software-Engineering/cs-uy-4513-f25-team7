class Post < ApplicationRecord
  belongs_to :user
  belongs_to :dex_species, optional: true
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :post_type, presence: true, inclusion: { in: %w[Thread Meta Strategy Announcement] }

  scope :for_species, ->(species_id) { where(dex_species_id: species_id) }
  scope :general, -> { where(dex_species_id: nil) }
end
