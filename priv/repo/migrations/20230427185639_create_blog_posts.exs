defmodule Blogex.Repo.Migrations.CreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add :title, :string
      add :body, :string
      add :views, :integer
      add :likes, :integer
      add :tags, {:array, :string}
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:blog_posts, [:user_id])
  end
end
