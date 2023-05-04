defmodule Blogex.Repo.Migrations.ModifyPosts do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      modify :likes, :integer, default: 0
      modify :views, :integer, default: 0
    end
  end
end
