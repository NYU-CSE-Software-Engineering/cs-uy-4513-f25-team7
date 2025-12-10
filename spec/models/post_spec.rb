require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'optionally belongs to a dex_species' do
      association = described_class.reflect_on_association(:dex_species)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be true
    end

    it 'has many comments' do
      association = described_class.reflect_on_association(:comments)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe 'validations' do
    it 'requires a title' do
      post = Post.new(title: nil)
      post.valid?
      expect(post.errors[:title]).to include("can't be blank")
    end

    it 'requires a body' do
      post = Post.new(body: nil)
      post.valid?
      expect(post.errors[:body]).to include("can't be blank")
    end

    it 'requires a valid post_type' do
      post = Post.new(post_type: 'InvalidType')
      post.valid?
      expect(post.errors[:post_type]).to include("is not included in the list")
    end

    it 'accepts valid post_types' do
      %w[Thread Meta Strategy Announcement].each do |type|
        post = Post.new(post_type: type)
        post.valid?
        expect(post.errors[:post_type]).to be_empty
      end
    end
  end
end
