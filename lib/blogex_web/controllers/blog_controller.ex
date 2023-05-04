defmodule BlogexWeb.BlogController do
  use BlogexWeb, :controller

  import Ecto.Query

  alias Blogex.Repo

  alias Blogex.Blog.Post

  alias Blogex.Accounts

  plug :correct_page?

  @per_page 15

  def index(conn, _) do
    query = create_query(conn)

    conn
    |> assigns(query)
    |> get_posts_for_current_page(query)
    |> render("index.html")
  end

  def show(conn, %{"name" => name}) do
    try do
      user_id = Accounts.get_user_by_name!(name).id

      query =
        from p in create_query(conn),
          where: p.user_id == ^user_id,
          preload: [:user]

      conn
      |> assigns(query)
      |> get_posts_for_current_page(query)
      |> render("show.html", user: Accounts.get_user_by_name!(name))
    rescue
      _ in Ecto.NoResultsError ->
        conn
        |> put_flash(:error, "No such user.")
        |> redirect(to: Routes.blog_path(conn, :index))
    end
  end

  defp correct_page?(conn, _) do
    page = String.to_integer(conn.params["page"] || "1")
    name = conn.params["name"]

    if page < 1 do
      path =
        if name do
          Routes.blog_path(conn, :show, name)
        else
          Routes.blog_path(conn, :index)
        end

      conn
      |> put_flash(:error, "Invalid page number.")
      |> redirect(to: path)
      |> halt()
    end

    conn
  end

  defp assigns(conn, query) do
    page = String.to_integer(conn.params["page"] || "1")
    sort_by = String.to_atom(conn.params["sort_by"] || "id")
    order = String.to_atom(conn.params["order"] || "desc")
    total_count = Repo.aggregate(query, :count, :id)
    total_pages = div(total_count + @per_page - 1, @per_page)

    conn
    |> assign(:total_pages, total_pages)
    |> assign(:page, page)
    |> assign(:sort_by, sort_by)
    |> assign(:order, order)
  end

  defp get_posts_for_current_page(conn, query) do
    page = String.to_integer(conn.params["page"] || "1")
    offset = (page - 1) * @per_page

    query =
      from p in query,
        preload: [:user],
        limit: ^@per_page,
        offset: ^offset

    try do
      conn
      |> assign(:posts,  Repo.all(query))
    rescue
      _ ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: Routes.blog_path(conn, :index))
        |> halt()
    end
  end

  defp create_query(conn) do
    sort_by = String.to_atom(conn.params["sort_by"] || "inserted_at")
    order = String.to_atom(conn.params["order"] || "desc")

    from p in Post, order_by: [{^order, ^sort_by}]
  end
end
