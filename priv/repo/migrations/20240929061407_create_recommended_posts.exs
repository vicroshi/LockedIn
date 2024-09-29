defmodule LockedIn.Repo.Migrations.CreateRecommendedPosts do
  use Ecto.Migration

  def change do
    create table(:recommended_posts, primary_key: false) do
      add :rating, :float
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :post_id, references(:posts, on_delete: :delete_all), primary_key: true
      timestamps(type: :utc_datetime)
    end
    create index(:recommended_posts, [:post_id])
  end
end
