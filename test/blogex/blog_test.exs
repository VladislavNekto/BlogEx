defmodule Blogex.BlogTest do
  use Blogex.DataCase

  alias Blogex.Blog

  alias Blogex.Blog.{Post, Comment}
  import Blogex.BlogFixtures
  import Blogex.AccountsFixtures

  describe "get_post!/1" do
    test "raise if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_post!(-1)
      end
    end
    test "return post with the given id" do
      %{id: id} = post = post_fixture()
      assert %Post{id: ^id} = Blog.get_post!(post.id)
    end
  end

  describe "create_post/1" do
    test "require attrs to be set" do
      {:error, changeset} = Blog.create_post(%{})
      assert %{
        body: ["can't be blank"], title: ["can't be blank"], user_id: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "validates maximum values for title and body" do
      too_long = String.duplicate("blog", 1500)
      {:error, changeset} = Blog.create_post(%{title: too_long, body: too_long, user_id: 1})
      assert %{
        body: ["should be at most 5000 character(s)"],
        title: ["should be at most 100 character(s)"]
      } = errors_on(changeset)
    end
  end

  describe "get_comments_by_post/1" do
    test "return comments for the given post" do
      post = post_fixture()
      comment_fixture(post_id: post.id)
      comment_fixture(post_id: post.id)
      assert [%Comment{}, %Comment{}] = Blog.get_comments_by_post(post.id)
    end

    test "return empty list if no comments for the given post" do
      post = post_fixture()
      assert [] = Blog.get_comments_by_post(post.id)
    end

    test "return empty list if post does not exist" do
      assert [] = Blog.get_comments_by_post(-1)
    end
  end

  describe "create_comment/1" do
    test "require attrs to be set" do
      {:error, changeset} = Blog.create_comment(%{})
      assert %{
        body: ["can't be blank"], user_id: ["can't be blank"], post_id: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "validates maximum values for body" do
      too_long = String.duplicate("blog", 1500)
      {:error, changeset} = Blog.create_comment(%{body: too_long, user_id: 1, post_id: 1})
      assert %{body: ["should be at most 500 character(s)"]} = errors_on(changeset)
    end

    test "return comment if valid attrs" do
      {:ok, comment} = Blog.create_comment(valid_comment_attributes())
      assert %Comment{} = comment
    end
  end

  describe "update_post/2" do
    test "require attrs to be set" do
      post = post_fixture()
      {:error, changeset} = Blog.update_post(post, %{title: "", body: ""})
      assert %{
        body: ["can't be blank"], title: ["can't be blank"]
      } = errors_on(changeset)
    end
    test "validates maximum values for title and body" do
      post = post_fixture()
      too_long = String.duplicate("blog", 1500)
      {:error, changeset} = Blog.update_post(post, %{title: too_long, body: too_long})
      assert %{
        body: ["should be at most 5000 character(s)"],
        title: ["should be at most 100 character(s)"]
      } = errors_on(changeset)
    end
  end

  describe "delete_post/1" do
    test "delete post" do
      post = post_fixture()
      assert :ok = Blog.delete_post(post)
    end

    test "delete post and its comments" do
      post = post_fixture()
      comment_fixture(post_id: post.id)
      comment_fixture(post_id: post.id)
      Blog.delete_post(post)
      assert [] = Blog.get_comments_by_post(post.id)
    end
  end

  describe "user_has_post?/2" do
    test "return true if user has post" do

      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert Blog.user_has_post?(post, user.id)
    end

    test "return false if user does not have post" do
      user = user_fixture()
      post = post_fixture()
      refute Blog.user_has_post?(post, user.id)
    end

    test "return true if user admin" do
      admin = admin_fixture()
      post = post_fixture()
      IO.inspect(admin)
      assert Blog.user_has_post?(post, admin.id)
    end
  end

  describe "increment_views_and_return_post/1" do
    test "increment views and return post" do
      post = post_fixture()
      assert %Post{views: 1} = Blog.increment_views_and_return_post(post.id)
    end
  end
end
