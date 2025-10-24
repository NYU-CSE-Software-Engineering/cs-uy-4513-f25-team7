require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @post = Post.new(title: "Test Post", content: "Test Content")
  end

  test "should be valid" do
    assert @post.valid?
  end

  test "title should be present" do
    @post.title = "   "
    assert_not @post.valid?
  end

  test "content should be present" do
    @post.content = "   "
    assert_not @post.valid?
  end

  test "should have many tags through post_tags" do
    @post.save
    tag1 = Tag.create!(name: "ruby")
    tag2 = Tag.create!(name: "rails")
    
    @post.tags << tag1
    @post.tags << tag2
    
    assert_equal 2, @post.tags.count
    assert_includes @post.tags, tag1
    assert_includes @post.tags, tag2
  end

  test "should have many votes" do
    @post.save
    vote1 = @post.votes.create!(value: 1, ip_address: "127.0.0.1")
    vote2 = @post.votes.create!(value: -1, ip_address: "127.0.0.2")
    
    assert_equal 2, @post.votes.count
    assert_includes @post.votes, vote1
    assert_includes @post.votes, vote2
  end

  test "should destroy associated post_tags when destroyed" do
    @post.save
    tag = Tag.create!(name: "ruby")
    @post.tags << tag
    
    assert_difference 'PostTag.count', -1 do
      @post.destroy
    end
  end

  test "should destroy associated votes when destroyed" do
    @post.save
    @post.votes.create!(value: 1, ip_address: "127.0.0.1")
    
    assert_difference 'Vote.count', -1 do
      @post.destroy
    end
  end

  test "should not destroy associated tags when destroyed" do
    @post.save
    tag = Tag.create!(name: "ruby")
    @post.tags << tag
    
    assert_no_difference 'Tag.count' do
      @post.destroy
    end
  end

  test "search should return posts matching query" do
    post1 = Post.create!(title: "Ruby on Rails", content: "Rails is great")
    post2 = Post.create!(title: "JavaScript Guide", content: "JS is awesome")
    post3 = Post.create!(title: "Python Tutorial", content: "Python is powerful")
    
    results = Post.search("rails")
    assert_includes results, post1
    assert_not_includes results, post2
    assert_not_includes results, post3
  end

  test "search should be case insensitive" do
    post1 = Post.create!(title: "Ruby on Rails", content: "Rails is great")
    post2 = Post.create!(title: "JavaScript Guide", content: "JS is awesome")
    
    results = Post.search("RAILS")
    assert_includes results, post1
    assert_not_includes results, post2
  end

  test "search should match content" do
    post1 = Post.create!(title: "Programming", content: "Ruby is a great language")
    post2 = Post.create!(title: "Web Development", content: "JavaScript is essential")
    
    results = Post.search("ruby")
    assert_includes results, post1
    assert_not_includes results, post2
  end

  test "search should return all posts when query is empty" do
    post1 = Post.create!(title: "Post 1", content: "Content 1")
    post2 = Post.create!(title: "Post 2", content: "Content 2")
    
    results = Post.search("")
    assert_includes results, post1
    assert_includes results, post2
  end

  test "search should return all posts when query is nil" do
    post1 = Post.create!(title: "Post 1", content: "Content 1")
    post2 = Post.create!(title: "Post 2", content: "Content 2")
    
    results = Post.search(nil)
    assert_includes results, post1
    assert_includes results, post2
  end

  test "vote_score should return sum of vote values" do
    @post.save
    @post.votes.create!(value: 1, ip_address: "127.0.0.1")
    @post.votes.create!(value: 1, ip_address: "127.0.0.2")
    @post.votes.create!(value: -1, ip_address: "127.0.0.3")
    
    assert_equal 1, @post.vote_score
  end

  test "vote_score should return 0 when no votes" do
    @post.save
    assert_equal 0, @post.vote_score
  end

  test "vote_score should handle negative scores" do
    @post.save
    @post.votes.create!(value: -1, ip_address: "127.0.0.1")
    @post.votes.create!(value: -1, ip_address: "127.0.0.2")
    
    assert_equal -2, @post.vote_score
  end

  test "voted_by? should return true when user has voted" do
    @post.save
    @post.votes.create!(value: 1, ip_address: "127.0.0.1")
    
    # Note: This test assumes the voted_by? method checks IP address
    # The actual implementation may differ based on user authentication
    assert @post.voted_by?("127.0.0.1")
  end

  test "voted_by? should return false when user has not voted" do
    @post.save
    assert_not @post.voted_by?("127.0.0.1")
  end

  test "voted_by? should return false when user is nil" do
    @post.save
    assert_not @post.voted_by?(nil)
  end

  test "should handle tags with special characters" do
    @post.save
    tag = Tag.create!(name: "c++")
    @post.tags << tag
    
    assert_includes @post.tags, tag
  end

  test "should handle tags with numbers" do
    @post.save
    tag = Tag.create!(name: "ruby2")
    @post.tags << tag
    
    assert_includes @post.tags, tag
  end

  test "should handle tags with hyphens" do
    @post.save
    tag = Tag.create!(name: "ruby-on-rails")
    @post.tags << tag
    
    assert_includes @post.tags, tag
  end

  test "should handle tags with underscores" do
    @post.save
    tag = Tag.create!(name: "ruby_on_rails")
    @post.tags << tag
    
    assert_includes @post.tags, tag
  end

  test "should handle tags with dots" do
    @post.save
    tag = Tag.create!(name: "asp.net")
    @post.tags << tag
    
    assert_includes @post.tags, tag
  end

  test "should handle tags with spaces" do
    @post.save
    tag = Tag.create!(name: "ruby on rails")
    @post.tags << tag
    
    assert_includes @post.tags, tag
  end

  test "should handle duplicate tags" do
    @post.save
    tag = Tag.create!(name: "ruby")
    
    # Adding the same tag twice should not create duplicates
    @post.tags << tag
    @post.tags << tag
    
    assert_equal 1, @post.tags.count
  end

  test "should handle many tags" do
    @post.save
    10.times do |i|
      tag = Tag.create!(name: "tag#{i}")
      @post.tags << tag
    end
    
    assert_equal 10, @post.tags.count
  end

  test "should handle tags with unicode characters" do
    @post.save
    tag = Tag.create!(name: "ruby-ruby")
    @post.tags << tag
    
    assert_includes @post.tags, tag
  end

  test "should maintain referential integrity with tags" do
    @post.save
    tag = Tag.create!(name: "ruby")
    @post.tags << tag
    
    # Verify the association
    assert_includes @post.tags, tag
    assert_includes tag.posts, @post
    
    # Verify the join table
    assert PostTag.exists?(post: @post, tag: tag)
  end

  test "should handle tag removal" do
    @post.save
    tag = Tag.create!(name: "ruby")
    @post.tags << tag
    
    assert_equal 1, @post.tags.count
    
    @post.tags.delete(tag)
    assert_equal 0, @post.tags.count
  end

  test "should handle tag clearing" do
    @post.save
    tag1 = Tag.create!(name: "ruby")
    tag2 = Tag.create!(name: "rails")
    @post.tags << tag1
    @post.tags << tag2
    
    assert_equal 2, @post.tags.count
    
    @post.tags.clear
    assert_equal 0, @post.tags.count
  end

  test "should handle tag replacement" do
    @post.save
    tag1 = Tag.create!(name: "ruby")
    tag2 = Tag.create!(name: "rails")
    @post.tags << tag1
    
    assert_equal 1, @post.tags.count
    assert_includes @post.tags, tag1
    
    @post.tags = [tag2]
    assert_equal 1, @post.tags.count
    assert_includes @post.tags, tag2
    assert_not_includes @post.tags, tag1
  end

  test "should handle empty tag list" do
    @post.save
    @post.tags = []
    assert_equal 0, @post.tags.count
  end

  test "should handle nil tag list" do
    @post.save
    @post.tags = nil
    assert_equal 0, @post.tags.count
  end
end
