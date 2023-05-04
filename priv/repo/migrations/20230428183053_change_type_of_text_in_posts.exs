defmodule Blogex.Repo.Migrations.ChangeTypeOfTextInPosts do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      modify :body, :text
    end
  end
end
