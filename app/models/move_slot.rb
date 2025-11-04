# app/models/move_slot.rb
class MoveSlot < ApplicationRecord
  belongs_to :team_slot
  validates :index, inclusion: { in: 0..3 }
  validates :move_id, uniqueness: { scope: :team_slot_id, message: "duplicate move" }, allow_nil: true
end
