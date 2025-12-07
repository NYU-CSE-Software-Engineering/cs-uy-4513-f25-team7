class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  validates :user_id, presence: true
  validates :favoritable_id, presence: true
  validates :favoritable_type, presence: true
  validates :favoritable_id, uniqueness: { scope: [:user_id, :favoritable_type], message: "has already been favorited" }
end
