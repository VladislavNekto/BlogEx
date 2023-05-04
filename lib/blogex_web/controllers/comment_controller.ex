defmodule BlogexWeb.CommentController do
  use BlogexWeb, :controller

  alias Blogex.Blog
  alias BlogexWeb.PostController
  alias BlogexWeb.PostView

  def create(conn, %{"comment" => comment_params}) do
    comment_params = Map.put(comment_params, "user_id", conn.assigns.current_user.id)

    if Blog.get_post!(comment_params["post_id"]) do
      case Blog.create_comment(comment_params) do
        {:ok, comment} ->
          conn
          |> put_flash(:info, "Comment created successfully.")
          |> redirect(to: Routes.post_path(conn, :show, comment.post_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> assign(:changeset, changeset)
          |> put_view(PostView)
          |> PostController.show(%{"id" => comment_params["post_id"]})
      end
    else
      conn
      |> put_flash(:error, "No such post.")
      |> redirect(to: Routes.blog_path(conn, :index))
    end
  end
end
