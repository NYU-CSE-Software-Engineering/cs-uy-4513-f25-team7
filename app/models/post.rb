class Post < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :votes, dependent: :destroy
  
  validates :title, presence: true
  validates :content, presence: true
  
  def self.search(query)
    if query.present?
      where("title ILIKE ? OR content ILIKE ?", "%#{query}%", "%#{query}%")
    else
      all
    end
  end
  
  def vote_score
    votes.sum(:value)
  end
  
  def voted_by?(user)
    return false unless user
    votes.exists?(user: user)
  end
end
