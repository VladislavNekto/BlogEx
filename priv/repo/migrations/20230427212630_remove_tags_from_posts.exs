defmodule Blogex.Repo.Migrations.RemoveTagsFromPosts do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      remove :tags
    end
  end
end
