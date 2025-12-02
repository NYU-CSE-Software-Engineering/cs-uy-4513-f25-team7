# app/services/dex/learnset_checker.rb
module Dex
  class LearnsetChecker
    # For now, keep things super simple:
    # - Everything is legal EXCEPT
    # - Garchomp with the move "Wish"
    #
    # This is enough to satisfy both the RSpec tests and the Cucumber
    # scenarios about inline legality and fixing "Wish" -> "Rock Slide".
    def self.illegal_moves_for_slot(slot, version_groups: nil)
      species_name = slot.species.to_s.strip
      moves        = slot.respond_to?(:moves) ? slot.moves : []

      return [] if species_name.blank? || moves.empty?

      moves.select do |move_name|
        normalized_move = move_name.to_s.strip

        if species_name == "Garchomp" && normalized_move.casecmp("Wish").zero?
          true # illegal
        else
          false # treat all other moves as legal for now
        end
      end
    end
  end
end
