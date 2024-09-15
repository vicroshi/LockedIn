defmodule LockedIn.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false
      add :is_read, :boolean, default: false
      add :sender_id, references(:users, on_delete: :nothing), null: false
      add :receiver_id, references(:users, on_delete: :nothing), null: false
      timestamps(type: :utc_datetime)
    end
  end
end
