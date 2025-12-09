class Post < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :votes, dependent: :destroy
  
  validates :title, presence: true
  validates :content, presence: true
  
  def self.search(query)
    if query.present?
      # Use LIKE for SQLite compatibility (ILIKE is PostgreSQL only)
      where("LOWER(title) LIKE LOWER(?) OR LOWER(content) LIKE LOWER(?)", "%#{query}%", "%#{query}%")
    else
      all
    end
  end
  
  def vote_score
    return 0 unless ActiveRecord::Base.connection.table_exists?('votes')
    votes.sum(:value)
  end
  
  def voted_by?(user)
    return false unless user
    return false unless ActiveRecord::Base.connection.table_exists?('votes')
    votes.exists?(user: user)
  end
  
  def tag_names
    tags.pluck(:name).join(', ')
  end
  
  def tag_names=(names)
    return if names.blank?
    
    normalized_names = names.split(',').map(&:strip).reject(&:blank?)
      .map { |name| name.downcase.strip }
    
    tag_objects = normalized_names.map do |normalized_name|
      Tag.find_or_create_by(name: normalized_name)
    end
    
    self.tags = tag_objects
  end
  
  def self.search_with_tags(query)
    if query.present?
      search_term = "%#{query}%"
      left_joins(:tags)
        .where("LOWER(posts.title) LIKE LOWER(?) OR LOWER(posts.content) LIKE LOWER(?) OR LOWER(tags.name) LIKE LOWER(?)", 
               search_term, search_term, search_term)
        .distinct
    else
      all
    end
  end
end
