class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  enum post_type: { thread: 0, meta: 1, review: 2, strategy: 3, announcement: 4 }

  validates :title, presence: true
  validates :body, presence: true
end
