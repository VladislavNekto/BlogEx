defmodule Blogex.Blog.Comment do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blogex.Accounts.User
  alias Blogex.Blog.Post

  schema "blog_comments" do
    field :body, :string
    field :user_id, :id
    field :post_id, :id

    belongs_to :user, User, define_field: false
    belongs_to :post, Post, define_field: false

    timestamps()
  end

  def creation_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :user_id, :post_id])
    |> validate_required([:body, :user_id, :post_id])
    |> validate_length(:body, min: 1, max: 500)
  end
end
