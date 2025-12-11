class Post < ApplicationRecord
  include ProfanityFilter

  belongs_to :user
  belongs_to :dex_species, optional: true
  has_many :comments, dependent: :destroy
  # Conditional associations - only if tables exist
  has_many :post_tags, dependent: :destroy, class_name: 'PostTag', foreign_key: 'post_id'
  has_many :tags, through: :post_tags, source: :tag
  has_many :votes, dependent: :destroy, class_name: 'Vote', foreign_key: 'post_id'

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
    return '' unless ActiveRecord::Base.connection.table_exists?('tags')
    return '' unless respond_to?(:tags)
    begin
      tags.pluck(:name).join(', ')
    rescue ActiveRecord::StatementInvalid, NoMethodError
      ''
    end
  end

  def tag_names=(names)
    return if names.blank?
    return unless ActiveRecord::Base.connection.table_exists?('tags')
    return unless defined?(Tag)
    begin
      normalized = names.split(',').map { |n| n.strip.downcase }.reject(&:blank?)
      @pending_tag_names = normalized
      self.tags = normalized.map { |n| Tag.find_or_create_by(name: n) }
    rescue ActiveRecord::StatementInvalid, NameError
      # Silently fail if tags table doesn't exist or Tag model not available
    end
  end

  def self.search(query)
    if query.present?
      where("LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)", "%#{query}%", "%#{query}%")
    else
      all
    end
  end

  def self.search_with_tags(query)
    return all unless query.present?
    return search(query) unless ActiveRecord::Base.connection.table_exists?('tags')
    
    term = "%#{query}%"
    left_joins(:tags)
      .where("LOWER(posts.title) LIKE LOWER(?) OR LOWER(posts.body) LIKE LOWER(?) OR LOWER(tags.name) LIKE LOWER(?)",
             term, term, term)
      .distinct
  end

  def vote_score
    return 0 unless ActiveRecord::Base.connection.table_exists?('votes')
    return 0 unless respond_to?(:votes)
    begin
      votes.sum(:value)
    rescue ActiveRecord::StatementInvalid, NoMethodError
      0
    end
  end

  def voted_by?(ip_address)
    return false unless ip_address
    return false unless ActiveRecord::Base.connection.table_exists?('votes')
    return false unless respond_to?(:votes)
    begin
      votes.exists?(ip_address: ip_address)
    rescue ActiveRecord::StatementInvalid, NoMethodError
      false
    end
  end

  private

  def validate_tag_lengths
    return unless ActiveRecord::Base.connection.table_exists?('tags')
    return unless defined?(Tag)
    begin
      names = @pending_tag_names || (respond_to?(:tags) ? tags&.map(&:name) : []) || []
      too_long = names.find { |n| n.length > 50 }
      if too_long
        errors.add(:base, "Tag '#{too_long}' is too long")
      end
    rescue ActiveRecord::StatementInvalid, NoMethodError
      # Silently skip validation if tags association fails
    end
  end
end
