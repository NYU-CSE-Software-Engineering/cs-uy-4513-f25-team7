class Tag < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :popular, ->(limit_count = 10) {
    left_joins(:posts)
      .group('tags.id')
      .order(Arel.sql('COUNT(posts.id) DESC'))
      .limit(limit_count)
  }
end

