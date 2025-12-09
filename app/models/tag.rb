class Tag < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :name, length: { maximum: 255 }
  
  before_save :normalize_name
  
  def self.popular(limit = 10)
    joins(:posts)
      .group('tags.id, tags.name')
      .order('COUNT(posts.id) DESC')
      .limit(limit)
  end
  
  private
  
  def normalize_name
    self.name = name.downcase.strip
  end
end
