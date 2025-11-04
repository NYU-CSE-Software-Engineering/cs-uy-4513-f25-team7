require 'rails_helper'

RSpec.describe Post, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }
  it { should belong_to(:user) }
  it { should define_enum_for(:post_type).with_values(thread: 0, meta: 1, review: 2, strategy: 3, announcement: 4) }
  it { should have_many(:comments).dependent(:destroy) }
end
