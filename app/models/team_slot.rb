class TeamSlot < ApplicationRecord
  belongs_to :team

  validates :slot_index, presence: true, inclusion: { in: 1..6 }

  scope :by_slot, -> { order(:slot_index) }

  STAT_KEYS = %w[HP Atk Def SpA SpD Spe].freeze

  # --- EV / IV helpers ---

  def evs_hash
    {
      "HP"  => ev_hp,
      "Atk" => ev_atk,
      "Def" => ev_def,
      "SpA" => ev_spa,
      "SpD" => ev_spd,
      "Spe" => ev_spe
    }
  end

  def ivs_hash
    {
      "HP"  => iv_hp,
      "Atk" => iv_atk,
      "Def" => iv_def,
      "SpA" => iv_spa,
      "SpD" => iv_spd,
      "Spe" => iv_spe
    }
  end

  # --- Moves ---

  # Normalized list of move names (ignores blanks)
  def moves
    [move_1, move_2, move_3, move_4].compact_blank
  end

  alias_method :moves_array, :moves

  # --- Legality flags ---

  # DB column is probably :illegality_reason; tests & code use illegal_reasons.
  # Provide a clean alias both ways.
  def illegal_reasons
    self.illegality_reason
  end

  def illegal_reasons=(value)
    self.illegality_reason = value
  end

  # Used by Team#mark_legality!, but safe to call directly too
  def illegal_moves(version_groups: nil)
    Dex::LearnsetChecker.illegal_moves_for_slot(self, version_groups: version_groups)
  end

  def recompute_legality!(version_groups: nil)
    illegals = illegal_moves(version_groups: version_groups)

    if illegals.any?
      self.illegal         = true
      self.illegal_reasons = illegals.map { |m| "#{m} cannot be learned" }.join(", ")
    else
      self.illegal         = false
      self.illegal_reasons = nil
    end

    save! if persisted? && changed?
    self
  end
end
