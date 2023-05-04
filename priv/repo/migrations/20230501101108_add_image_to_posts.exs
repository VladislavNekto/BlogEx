defmodule Blogex.Repo.Migrations.AddImageToPosts do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      add :image, :string, default: ""
    end
  end
end
