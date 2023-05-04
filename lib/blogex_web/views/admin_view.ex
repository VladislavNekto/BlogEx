defmodule BlogexWeb.AdminView do
  use BlogexWeb, :view

  import BlogexWeb.Helpers


  def cur_path(conn) do
    Routes.admin_path(conn, :index) <> "?" <> URI.encode_query(conn.query_params)
  end

  def button_helper(conn, key, value) do
  "window.location.href='#{new_path(conn, key, value)}'"
  end
end
