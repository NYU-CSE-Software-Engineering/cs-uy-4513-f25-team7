# app/models/concerns/profanity_filter.rb
module ProfanityFilter
  extend ActiveSupport::Concern

  BANNED_WORDS = %w[
    darn
    heck
  ].freeze

  included do
    validate :title_must_not_contain_profanity, if: -> { respond_to?(:title) }
    validate :body_must_not_contain_profanity,  if: -> { respond_to?(:body) }
  end

  private

  def contains_profanity?(text)
    return false if text.blank?

    pattern = Regexp.union(
      BANNED_WORDS.map { |w| /\b#{Regexp.escape(w)}\b/i }
    )

    text.match?(pattern)
  end

  def title_must_not_contain_profanity
    return unless contains_profanity?(title)

    errors.add(:title, "contains inappropriate language")
  end

  def body_must_not_contain_profanity
    return unless contains_profanity?(body)

    errors.add(:body, "contains inappropriate language")
  end
end
