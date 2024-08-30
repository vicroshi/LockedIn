defmodule LockedIn.Repo.Migrations.CreateConnections do
  use Ecto.Migration

  def change do
    create table(:connections, primary_key: false) do
      add :has_accepted, :boolean, default: false, null: false
      add :requester_id, references(:users, on_delete: :delete_all), primary_key: true
      add :requestee_id, references(:users, on_delete: :delete_all), primary_key: true

      timestamps(type: :utc_datetime)
    end

    create index(:connections, [:requester_id])
    create index(:connections, [:requestee_id])
    create index(:connections, [:requestee_id,:requester_id])
  end
end
