require "test_helper"

class TagTest < ActiveSupport::TestCase
  def setup
    @tag = Tag.new(name: "ruby")
  end

  test "should be valid" do
    assert @tag.valid?
  end

  test "name should be present" do
    @tag.name = "   "
    assert_not @tag.valid?
  end

  test "name should be unique" do
    duplicate_tag = @tag.dup
    @tag.save
    assert_not duplicate_tag.valid?
  end

  test "name should be unique case insensitive" do
    duplicate_tag = @tag.dup
    duplicate_tag.name = @tag.name.upcase
    @tag.save
    assert_not duplicate_tag.valid?
  end

  test "name should be normalized to lowercase" do
    @tag.name = "RUBY"
    @tag.save
    assert_equal "ruby", @tag.name
  end

  test "name should be trimmed" do
    @tag.name = "  ruby  "
    @tag.save
    assert_equal "ruby", @tag.name
  end

  test "should have many posts through post_tags" do
    @tag.save
    post1 = Post.create!(title: "Post 1", content: "Content 1")
    post2 = Post.create!(title: "Post 2", content: "Content 2")
    
    @tag.posts << post1
    @tag.posts << post2
    
    assert_equal 2, @tag.posts.count
    assert_includes @tag.posts, post1
    assert_includes @tag.posts, post2
  end

  test "should destroy associated post_tags when destroyed" do
    @tag.save
    post = Post.create!(title: "Test Post", content: "Test Content")
    @tag.posts << post
    
    assert_difference 'PostTag.count', -1 do
      @tag.destroy
    end
  end

  test "should not destroy associated posts when destroyed" do
    @tag.save
    post = Post.create!(title: "Test Post", content: "Test Content")
    @tag.posts << post
    
    assert_no_difference 'Post.count' do
      @tag.destroy
    end
  end

  test "popular should return tags ordered by usage" do
    # Create tags with different usage counts
    ruby_tag = Tag.create!(name: "ruby")
    rails_tag = Tag.create!(name: "rails")
    js_tag = Tag.create!(name: "javascript")
    
    # Create posts with different tag usage
    5.times do |i|
      post = Post.create!(title: "Ruby Post #{i}", content: "Content")
      post.tags << ruby_tag
    end
    
    3.times do |i|
      post = Post.create!(title: "Rails Post #{i}", content: "Content")
      post.tags << rails_tag
    end
    
    1.times do |i|
      post = Post.create!(title: "JS Post #{i}", content: "Content")
      post.tags << js_tag
    end
    
    popular_tags = Tag.popular(3)
    
    assert_equal "ruby", popular_tags.first.name
    assert_equal "rails", popular_tags.second.name
    assert_equal "javascript", popular_tags.third.name
  end

  test "popular should limit results" do
    # Create multiple tags
    10.times do |i|
      tag = Tag.create!(name: "tag#{i}")
      post = Post.create!(title: "Post #{i}", content: "Content")
      post.tags << tag
    end
    
    popular_tags = Tag.popular(5)
    assert_equal 5, popular_tags.count
  end

  test "should handle special characters in names" do
    special_tag = Tag.new(name: "c++")
    assert special_tag.valid?
    
    special_tag.save
    assert_equal "c++", special_tag.name
  end

  test "should handle long names" do
    long_name = "a" * 255
    @tag.name = long_name
    assert @tag.valid?
  end

  test "should not allow names longer than 255 characters" do
    long_name = "a" * 256
    @tag.name = long_name
    assert_not @tag.valid?
  end

  test "should create tag with find_or_create_by" do
    tag = Tag.find_or_create_by(name: "new_tag")
    assert tag.persisted?
    assert_equal "new_tag", tag.name
  end

  test "should find existing tag with find_or_create_by" do
    existing_tag = Tag.create!(name: "existing_tag")
    found_tag = Tag.find_or_create_by(name: "existing_tag")
    
    assert_equal existing_tag.id, found_tag.id
    assert_equal "existing_tag", found_tag.name
  end

  test "should normalize name in find_or_create_by" do
    tag = Tag.find_or_create_by(name: "  NEW_TAG  ")
    assert_equal "new_tag", tag.name
  end

  test "should handle empty name" do
    @tag.name = ""
    assert_not @tag.valid?
  end

  test "should handle nil name" do
    @tag.name = nil
    assert_not @tag.valid?
  end

  test "should handle names with only whitespace" do
    @tag.name = "   "
    assert_not @tag.valid?
  end

  test "should handle names with newlines and tabs" do
    @tag.name = "ruby\nrails\ttutorial"
    @tag.save
    assert_equal "ruby\nrails\ttutorial", @tag.name
  end

  test "should be case insensitive in validations" do
    @tag.save
    duplicate_tag = Tag.new(name: "RUBY")
    assert_not duplicate_tag.valid?
  end

  test "should count associated posts correctly" do
    @tag.save
    assert_equal 0, @tag.posts.count
    
    post = Post.create!(title: "Test Post", content: "Test Content")
    @tag.posts << post
    assert_equal 1, @tag.posts.count
  end

  test "should handle multiple posts with same tag" do
    @tag.save
    post1 = Post.create!(title: "Post 1", content: "Content 1")
    post2 = Post.create!(title: "Post 2", content: "Content 2")
    
    @tag.posts << post1
    @tag.posts << post2
    
    assert_equal 2, @tag.posts.count
    assert_includes @tag.posts, post1
    assert_includes @tag.posts, post2
  end

  test "should handle tag with no posts" do
    @tag.save
    assert_equal 0, @tag.posts.count
    assert @tag.posts.empty?
  end

  test "should handle tag with many posts" do
    @tag.save
    100.times do |i|
      post = Post.create!(title: "Post #{i}", content: "Content #{i}")
      @tag.posts << post
    end
    
    assert_equal 100, @tag.posts.count
  end

  test "should maintain referential integrity" do
    @tag.save
    post = Post.create!(title: "Test Post", content: "Test Content")
    @tag.posts << post
    
    # Verify the association
    assert_includes @tag.posts, post
    assert_includes post.tags, @tag
    
    # Verify the join table
    assert PostTag.exists?(post: post, tag: @tag)
  end
end
