defmodule BlogexWeb.PostControllerTest do
  use BlogexWeb.ConnCase
  alias Blogex.Blog

  import Blogex.BlogFixtures

  setup :register_and_log_in_user

  describe "GET /posts/new" do
    test "renders the new post page", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "New post"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.post_path(conn, :new))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "POST /posts" do
    test "creates a new post", %{conn: conn, user: user} do
      conn = post(conn, Routes.post_path(conn, :create), %{
        "post" => %{
          "title" => "New post",
          "body" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        }
      })

      post_id = Enum.find_value(conn.resp_headers, fn {k, v} -> if k == "location", do: v end) |> String.split("/") |> List.last |> String.to_integer()
      assert redirected_to(conn) == Routes.post_path(conn, :show, post_id)
      assert get_flash(conn, :info) =~ "Post created successfully"
      assert Blog.get_post!(post_id).title == "New post"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = post(conn, Routes.post_path(conn, :create), %{
        "post" => %{
          "title" => "New post",
          "body" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        }
      })

      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "/post/:id/edit (render edit page and edit)" do
    test "renders the edit post page", %{conn: conn, user: user} do
      post = post_fixture(user_id: user.id)
      conn = get(conn, Routes.post_path(conn, :edit, post.id))
      response = html_response(conn, 200)
      assert response =~ "Edit post"
    end

    test "redirects if user is not logged in" do
      post = post_fixture()
      conn = build_conn()
      conn = get(conn, Routes.post_path(conn, :edit, post.id))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "edit post", %{conn: conn, user: user} do
      post = post_fixture(user_id: user.id)
      conn = put(conn, Routes.post_path(conn, :update, post.id), %{
        "post" => %{
          "title" => "Updated post",
          "body" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        }
      })

      assert redirected_to(conn) == Routes.post_path(conn, :show, post.id)
      assert get_flash(conn, :info) =~ "Post updated successfully"
      assert Blog.get_post!(post.id).title == "Updated post"
    end

    test "redirect if user don't have rights to edit post", %{conn: conn, user: user} do
      post = post_fixture()
      conn = put(conn, Routes.post_path(conn, :update, post.id), %{
        "post" => %{
          "title" => "Updated post",
          "body" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        }
      })

      assert redirected_to(conn) == Routes.post_path(conn, :show, post.id)
      assert get_flash(conn, :error) =~ "You are not authorized to edit this post."
    end
  end

  describe "GET /post/:id/delete" do
    test "deletes a post", %{conn: conn, user: user} do
      post = post_fixture(user_id: user.id)
      conn = get(conn, Routes.post_path(conn, :delete, post.id))
      assert redirected_to(conn) == Routes.blog_path(conn, :index)
      assert get_flash(conn, :info) =~ "Post deleted successfully"
      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_post!(post.id)
      end
    end

    test "redirect if user don't have rights to delete post", %{conn: conn, user: user} do
      post = post_fixture()
      conn = get(conn, Routes.post_path(conn, :delete, post.id))
      assert redirected_to(conn) == Routes.post_path(conn, :show, post.id)
      assert get_flash(conn, :error) =~ "You are not authorized to edit this post."
    end
  end
end
