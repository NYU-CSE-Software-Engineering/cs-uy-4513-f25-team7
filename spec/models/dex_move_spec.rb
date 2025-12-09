require 'rails_helper'

RSpec.describe DexMove, type: :model do
  describe 'associations' do
    it 'has many dex_learnsets' do
      association = described_class.reflect_on_association(:dex_learnsets)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many dex_species through dex_learnsets' do
      association = described_class.reflect_on_association(:dex_species)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:dex_learnsets)
    end
  end

  describe 'validations' do
    it 'requires a name' do
      move = DexMove.new(name: nil)
      move.valid?
      expect(move.errors[:name]).to include("can't be blank")
    end
  end

  describe '.find_by_name_ci' do
    it 'finds moves case-insensitively' do
      move = DexMove.create!(name: 'Thunderbolt')
      expect(DexMove.find_by_name_ci('thunderbolt')).to eq(move)
      expect(DexMove.find_by_name_ci('THUNDERBOLT')).to eq(move)
    end
  end
end
