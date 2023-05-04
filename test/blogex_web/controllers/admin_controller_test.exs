defmodule BlogexWeb.AdminControllerTest do
  use BlogexWeb.ConnCase
  alias Blogex.Blog

  import Blogex.BlogFixtures
  import Blogex.AccountsFixtures

  setup :register_and_log_in_admin

  describe "GET /admin" do
    test "renders the admin page", %{conn: conn} do
      conn = get(conn, Routes.admin_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "Admin dashboard"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.admin_path(conn, :index))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "renders tab users", %{conn: conn} do
      user = user_fixture()

      conn = get(conn, Routes.admin_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ user.email
    end

    test "renders tab posts", %{conn: conn} do
      post = post_fixture()

      conn = get(conn, Routes.admin_path(conn, :index, tab: "posts"))
      response = html_response(conn, 200)
      assert response =~ post.title
    end
  end
end
