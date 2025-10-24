require "test_helper"

class TaggingIntegrationTest < ActionDispatch::IntegrationTest
  test "complete tagging workflow" do
    # Create post with tags
    post posts_url, params: { post: { title: "Ruby Guide", content: "Learn Ruby", tags: "ruby, programming" } }
    assert_redirected_to post_url(Post.last)
    
    # Verify tags were created
    assert_equal 2, Tag.count
    assert Tag.exists?(name: "ruby")
    assert Tag.exists?(name: "programming")
    
    # Verify post has tags
    post = Post.last
    assert_equal 2, post.tags.count
    assert_includes post.tags.pluck(:name), "ruby"
    assert_includes post.tags.pluck(:name), "programming"
    
    # Filter by tag
    get posts_url(tag: "ruby")
    assert_response :success
    assert_select "h1", "Ruby Guide"
    
    # Search by tag
    get posts_url(search: "ruby")
    assert_response :success
    assert_select "h1", "Ruby Guide"
  end
end
