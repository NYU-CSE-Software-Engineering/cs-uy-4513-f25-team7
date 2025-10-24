class Vote < ApplicationRecord
  belongs_to :post
  
  validates :value, inclusion: { in: [-1, 1] }
  validates :ip_address, presence: true
  validates :ip_address, uniqueness: { scope: :post_id }
end
