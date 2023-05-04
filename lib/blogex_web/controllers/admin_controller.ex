defmodule BlogexWeb.AdminController do
  use BlogexWeb, :controller

  import Ecto.Query

  alias Blogex.Repo
  alias Blogex.Accounts.User
  alias Blogex.Blog.Post

  plug :authorize_admin

  def index(conn, params) do
    sort_by = String.to_atom(params["sort_by"] || "id")
    order = String.to_atom(params["order"] || "asc")
    page = String.to_integer(params["page"] || "1")
    page = if page < 1 do
             1
           else
             page
           end
    per_page = String.to_integer(params["per_page"] || "50")

    tab = params["tab"] || "users"

    try do
      data = case tab do
        "users" ->
          Repo.all(from u in User, order_by: [{^order, ^sort_by}], limit: ^per_page, offset: (^page - 1) * ^per_page)
        "posts" ->
          Repo.all(from p in Post, order_by: [{^order, ^sort_by}], limit: ^per_page, offset: (^page - 1) * ^per_page)
        end
      total_count = case tab do
        "users" ->
          Repo.aggregate(User, :count, :id)
        "posts" ->
          Repo.aggregate(Post, :count, :id)
        end
      total_pages = div(total_count + per_page - 1, per_page)
      conn
      |> put_layout({BlogexWeb.LayoutView, "admin.html"})
      |> render("index.html", data: data, sort_by: sort_by, order: order, page: page, per_page: per_page, tab: tab, total_count: total_count, total_pages: total_pages)
    rescue
      _  ->
        conn
        |> put_flash(:error, "Something wrong.")
        |> redirect(to: Routes.admin_path(conn, :index))
    end
  end

  defp authorize_admin(conn, _) do
    if conn.assigns.current_user.admin do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to access this page.")
      |> redirect(to: Routes.blog_path(conn, :index))
    end
  end
end
