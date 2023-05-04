defmodule BlogexWeb.BlogControllerTest do
  use BlogexWeb.ConnCase

  import Blogex.BlogFixtures

  describe "GET /" do
    test "renders the index page", %{conn: conn} do
      post = post_fixture()
      conn = get(conn, Routes.blog_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ post.title
    end

    test "renders the index page with pagination", %{conn: conn} do
      posts = for _ <- 1..35, do: post_fixture()
      conn = get(conn, Routes.blog_path(conn, :index, page: 2))
      response = html_response(conn, 200)
      assert response =~ "Prev"
      assert response =~ "Next"
    end
  end

  describe "GET /user/:name" do
    test "renders the user page", %{conn: conn} do
      post = post_fixture()
      conn = get(conn, Routes.blog_path(conn, :show, post.user.name))
      response = html_response(conn, 200)
      assert response =~ post.title
    end

    test "redirects to index page if user does not exist", %{conn: conn} do
      conn = get(conn, Routes.blog_path(conn, :show, "unknown"))
      assert redirected_to(conn) == Routes.blog_path(conn, :index)
      assert get_flash(conn, :error) =~ "No such user."
    end

    test "renders the user page with pagination", %{conn: conn} do
      post = post_fixture()
      posts = for _ <- 1..35, do: post_fixture(user_id: post.user_id)
      conn = get(conn, Routes.blog_path(conn, :show, post.user.name, page: 2))
      response = html_response(conn, 200)
      assert response =~ "Prev"
      assert response =~ "Next"
    end
  end
end
