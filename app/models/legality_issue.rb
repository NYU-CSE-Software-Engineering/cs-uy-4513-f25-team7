# app/models/legality_issue.rb
class LegalityIssue < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :team_slot, optional: true
end
