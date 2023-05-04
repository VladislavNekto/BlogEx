defmodule Blogex.BlogFixtures do
  alias Blogex.Blog
  alias Blogex.Repo

  import Blogex.AccountsFixtures

  def valid_post_title, do: "Post #{abs(System.unique_integer())}"
  def valid_post_body, do: "Body #{abs(System.unique_integer())}"

  def valid_post_attributes(attrs \\ {}) do
    Enum.into(attrs, %{
      title: valid_post_title(),
      body: valid_post_body(),
      user_id: user_fixture().id
    })
  end

  def valid_comment_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      body: "Comment #{abs(System.unique_integer())}",
      post_id: post_fixture().id,
      user_id: user_fixture().id
    })
  end

  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> valid_post_attributes()
      |> Blog.create_post()
    post
    |> Repo.preload([:user])
  end

  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> valid_comment_attributes()
      |> Blog.create_comment()
    comment
  end
end
