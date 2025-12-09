require 'rails_helper'

RSpec.describe DexLearnset, type: :model do
  describe 'associations' do
    it 'belongs to a dex_species' do
      association = described_class.reflect_on_association(:dex_species)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to a dex_move' do
      association = described_class.reflect_on_association(:dex_move)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    it 'requires a method' do
      learnset = DexLearnset.new(method: nil)
      learnset.valid?
      expect(learnset.errors[:method]).to include("can't be blank")
    end
  end
end
