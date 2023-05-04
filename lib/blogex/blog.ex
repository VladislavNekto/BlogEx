defmodule Blogex.Blog do
  import Ecto.Query

  alias Blogex.Repo
  alias Blogex.Blog.{Post, Comment}
  alias Blogex.Accounts

  def change_post_creation(%Post{} = post, attrs \\ %{}) do
    Post.editing_changeset(post, attrs)
  end

  def create_post(attrs) do
    %Post{}
    |> Post.creation_changeset(attrs)
    |> Repo.insert()
  end

  def change_comment_creation(%Comment{} = comment, attrs \\ %{}) do
    Comment.creation_changeset(comment, attrs)
  end

  def create_comment(attrs) do
    %Comment{}
    |> Comment.creation_changeset(attrs)
    |> Repo.insert()
  end

  def get_post!(id) do
    Repo.get!(Post, id)
    |> Repo.preload(:user)
  end

  def get_comments_by_post(post_id) do
    query =
      from c in Comment,
        where: c.post_id == ^post_id,
        order_by: [asc: c.inserted_at],
        preload: [:user]

    Repo.all(query)
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.creation_changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete_all(Comment, post_id: post.id)
    Repo.delete(post)
    :ok
  end

  def user_has_post?(%Post{} = post, user_id) do
    user = Accounts.get_user!(user_id)

    cond do
      user.admin -> true
      user.id == post.user_id -> true
      true -> false
    end
  end

  def increment_views_and_return_post(id) do
    post = get_post!(id)

    {:ok, post} =
      post |> Post.increment_views_changeset(%{views: post.views + 1}) |> Repo.update()

    post
  end

  def create_post_with_image(%{"image" => %Plug.Upload{} = image} = post_params) do
    ext = Path.extname(image.filename)
    file_name = Ecto.UUID.generate() <> ext
    path_to_db = "/images/uploads/" <> file_name
    post_params = Map.put(post_params, "image", path_to_db)

    changeset = Post.creation_changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        path = (System.get_env("IMAGES_PATH") || "priv/static/images/uploads/") <> file_name
        File.cp(image.path, path)
        {:ok, post}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
