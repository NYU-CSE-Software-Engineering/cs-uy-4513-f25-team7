class User < ApplicationRecord
  devise :two_factor_authenticatable
  devise :registerable,
         :recoverable, :rememberable, :validatable

  has_many :teams, dependent: :destroy
end
