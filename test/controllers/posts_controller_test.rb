require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post with tags" do
    assert_difference('Post.count') do
      post posts_url, params: { post: { title: "Test Post", content: "Test Content", tags: "ruby, rails" } }
    end
    assert_redirected_to post_url(Post.last)
  end

  test "should create post without tags" do
    assert_difference('Post.count') do
      post posts_url, params: { post: { title: "Test Post", content: "Test Content" } }
    end
    assert_redirected_to post_url(Post.last)
  end

  test "should show post" do
    post = posts(:one)
    get post_url(post)
    assert_response :success
  end

  test "should get edit" do
    post = posts(:one)
    get edit_post_url(post)
    assert_response :success
  end

  test "should update post with tags" do
    post = posts(:one)
    patch post_url(post), params: { post: { title: "Updated", content: "Updated Content", tags: "updated, tags" } }
    assert_redirected_to post_url(post)
  end

  test "should destroy post" do
    post = posts(:one)
    assert_difference('Post.count', -1) do
      delete post_url(post)
    end
    assert_redirected_to posts_url
  end

  test "should filter posts by tag" do
    get posts_url(tag: "ruby")
    assert_response :success
  end

  test "should search posts" do
    get posts_url(search: "rails")
    assert_response :success
  end
end
