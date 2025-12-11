class Post < ApplicationRecord
  include ProfanityFilter

  belongs_to :user
  belongs_to :dex_species, optional: true
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :votes, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :post_type, presence: true, inclusion: { in: %w[Thread Meta Strategy Announcement] }
  validate :validate_tag_lengths

  scope :for_species, ->(species_id) { where(dex_species_id: species_id) }
  scope :general, -> { where(dex_species_id: nil) }

  # Compatibility aliases
  def content
    body
  end

  def content=(val)
    self.body = val
  end

  def tag_names
    tags.pluck(:name).join(', ')
  end

  def tag_names=(names)
    return if names.blank?
    normalized = names.split(',').map { |n| n.strip.downcase }.reject(&:blank?)
    @pending_tag_names = normalized
    self.tags = normalized.map { |n| Tag.find_or_create_by(name: n) }
  end

  def self.search(query)
    if query.present?
      where("LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)", "%#{query}%", "%#{query}%")
    else
      all
    end
  end

  def self.search_with_tags(query)
    if query.present?
      term = "%#{query}%"
      left_joins(:tags)
        .where("LOWER(posts.title) LIKE LOWER(?) OR LOWER(posts.body) LIKE LOWER(?) OR LOWER(tags.name) LIKE LOWER(?)",
               term, term, term)
        .distinct
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

  private

  def validate_tag_lengths
    names = @pending_tag_names || tags&.map(&:name) || []
    too_long = names.find { |n| n.length > 50 }
    if too_long
      errors.add(:base, "Tag '#{too_long}' is too long")
    end
  end
end
