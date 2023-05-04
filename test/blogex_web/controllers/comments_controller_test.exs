defmodule BlogexWeb.CommentsControllerTest do
  use BlogexWeb.ConnCase
  alias Blogex.Blog

  import Blogex.BlogFixtures

  setup :register_and_log_in_user

  describe "POST /comments/create" do
    test "creates a new comment", %{conn: conn, user: user} do
      post = post_fixture()
      conn = post(conn, Routes.comment_path(conn, :create), %{
        "comment" => %{
          "body" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
          "post_id" => post.id
        }
      })

      assert redirected_to(conn) == Routes.post_path(conn, :show, post.id)
      assert get_flash(conn, :info) =~ "Comment created successfully"
      assert Blog.get_comments_by_post(post.id) |> List.first() |> Map.get(:body) == "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    end
  end
end
