class User < ApplicationRecord
  devise :two_factor_authenticatable
  devise :registerable,
         :recoverable, :rememberable, :validatable

  has_many :teams, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
end
