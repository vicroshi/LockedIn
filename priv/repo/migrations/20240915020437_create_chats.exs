defmodule LockedIn.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :starter_id, references(:users, on_delete: :nothing), null: false
      add :chatter_id, references(:users, on_delete: :nothing), null: false
      # timestamps(type: :utc_datetime)
    end
    create unique_index(:chats, [:starter_id, :chatter_id])
    create index(:chats, [:chatter_id])

  end
end
