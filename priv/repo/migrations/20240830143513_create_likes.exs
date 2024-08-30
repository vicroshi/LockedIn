defmodule LockedIn.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :post_id, references(:posts, on_delete: :delete_all), primary_key: true

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:likes, [:user_id])
    create index(:likes, [:post_id])
    create index(:likes, [:post_id,:user_id])
  end
end
