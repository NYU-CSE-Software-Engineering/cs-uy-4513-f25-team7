class User < ApplicationRecord
  has_secure_password  # uses password_digest

  validates :email, presence: true, uniqueness: true
end
