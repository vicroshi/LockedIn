defmodule LockedIn.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :is_comment, :boolean, default: false, null: false
      add :recipient_id, references(:users, on_delete: :nothing)
      add :sender_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)
      add :is_read, :boolean, default: false, null: false
      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:recipient_id])
    create index(:notifications, [:sender_id])
  end
end
