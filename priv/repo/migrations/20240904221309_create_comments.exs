defmodule LockedIn.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :user_id, references(:users, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:comments, [:user_id])
    create index(:comments, [:post_id,:user_id])
  end
end
