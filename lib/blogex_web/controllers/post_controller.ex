defmodule BlogexWeb.PostController do
  use BlogexWeb, :controller

  alias Blogex.Blog
  alias Blogex.Blog.{Post, Comment}

  plug :user_has_rights? when action in [:edit, :update, :delete]
  plug :assign_changesets when action in [:new, :edit]
  plug :put_user_id when action in [:create, :reply]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def show(conn, %{"id" => id}) do
    IO.inspect(conn.assigns)
    try do
      post = Blog.increment_views_and_return_post(id)
      comments = Blog.get_comments_by_post(id)
      changeset = if conn.assigns[:changeset], do: conn.assigns.changeset, else: Blog.change_comment_creation(%Comment{})

        render(conn, "show.html",
          post: post,
          changeset: changeset,
          comments: comments
        )
    rescue
      _ in Ecto.NoResultsError ->
        conn
        |> put_flash(:error, "No such post.")
        |> redirect(to: Routes.blog_path(conn, :index))
    end
  end
  
  def create(conn, %{"post" => %{"image" => _} = post_params}) do
    case Blog.create_post_with_image(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"post" => post_params}) do
    case Blog.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    IO.inspect(post)

    render(conn, "edit.html", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Blog.get_post!(id)

    case Blog.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    Blog.delete_post(post)

    if conn.assigns.current_user.admin do
      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.admin_path(conn, :index, tab: "posts"))
    else
      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.blog_path(conn, :index))
    end
  end

  defp user_has_rights?(conn, _) do
    post = Blog.get_post!(conn.params["id"])

    if Blog.user_has_post?(post, conn.assigns.current_user.id) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to edit this post.")
      |> redirect(to: Routes.post_path(conn, :show, post.id))
      |> halt()
    end
  end

  defp assign_changesets(conn, _) do
    conn
    |> assign(:changeset, Blog.change_post_creation(%Post{}))
  end

  defp put_user_id(conn, _) do
    Map.put(conn, :params,
      Map.put(conn.params, "post",
        Map.put(conn.params["post"], "user_id", conn.assigns.current_user.id)))
  end
end
