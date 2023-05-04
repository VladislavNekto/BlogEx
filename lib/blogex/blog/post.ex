defmodule Blogex.Blog.Post do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blogex.Accounts.User

  schema "blog_posts" do
    field :body, :string
    field :title, :string
    field :views, :integer, default: 0
    field :image, :string, default: ""
    field :user_id, :id

    belongs_to :user, User, define_field: false

    timestamps()
  end

  def creation_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :user_id, :image])
    |> validate_required([:title, :body, :user_id])
    |> validate_length(:title, min: 1, max: 100)
    |> validate_length(:body, min: 1, max: 5000)
    |> validate_image()
  end

  def editing_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :image])
    |> validate_required([:title, :body])
    |> validate_length(:title, min: 1, max: 100)
    |> validate_length(:body, min: 1, max: 5000)
    |> validate_image()
  end

  def increment_views_changeset(post, attrs) do
    post
    |> cast(attrs, [:views])
    |> validate_required([:views])
    |> validate_number(:views, greater_than_or_equal_to: 0)
  end

  def validate_image(changeset) do
    if changeset.params["image"] == nil do
      changeset
    else
      changeset
      |> validate_format(:image, ~r/\.(jpg|jpeg|png|gif)$/, message: "is not a valid image")
    end
  end
end
