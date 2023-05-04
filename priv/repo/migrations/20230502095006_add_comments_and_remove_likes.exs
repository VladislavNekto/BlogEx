defmodule Blogex.Repo.Migrations.AddCommentsAndRemoveLikes do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      remove :likes
    end

    create table(:blog_comments) do
      add :body, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:blog_posts, on_delete: :nothing)

      timestamps()
    end
  end
end
