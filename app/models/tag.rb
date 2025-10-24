class Tag < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags
  
  validates :name, presence: true, uniqueness: true
  
  before_save :normalize_name
  
  private
  
  def normalize_name
    self.name = name.downcase.strip
  end
end
