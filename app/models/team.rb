# app/models/team.rb
class Team < ApplicationRecord
  belongs_to :user
  belongs_to :format, optional: true

  has_many :team_slots, -> { order(:position) }, dependent: :destroy, inverse_of: :team
  has_many :legality_issues, dependent: :destroy

  accepts_nested_attributes_for :team_slots,
                                allow_destroy: true,
                                reject_if: ->(attrs) {
                                  keys = %w[species_id ability_id item_id nature_id tera_type
                                            ev_hp ev_atk ev_def ev_spa ev_spd ev_spe
                                            iv_hp iv_atk iv_def iv_spa iv_spd iv_spe]
                                  all_slot_blank   = keys.all? { |k| attrs[k].blank? }
                                  all_moves_blank  = attrs['move_slots_attributes'].blank? ||
                                                     attrs['move_slots_attributes'].values.all? { |ms| ms['move_id'].blank? }
                                  all_slot_blank && all_moves_blank
                                }

  enum status:     { draft: 0, published: 1 }, _default: :draft
  enum visibility: { private_vis: 0, unlisted: 1, public_vis: 2 }, _prefix: :visibility

  validate :max_six_slots
  def max_six_slots
    if team_slots.reject(&:marked_for_destruction?).size > 6
      errors.add(:base, "A team can have at most 6 Pokémon")
    end
  end
end
