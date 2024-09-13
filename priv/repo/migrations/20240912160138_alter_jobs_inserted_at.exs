defmodule LockedIn.Repo.Migrations.AlterJobsInsertedAt do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      modify :inserted_at, :utc_datetime
    end
  end
end
