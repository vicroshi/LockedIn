defmodule LockedIn.Repo.Migrations.DropRedundantIndices do
  use Ecto.Migration

  def change do
    drop index(:connections, [:requester_id, :requestee_id], name: :connections_index)
    drop index(:connections, [:requester_id])

  end
end
