class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :post_type, presence: true, inclusion: { in: %w[Thread Meta Strategy Announcement] }
end
