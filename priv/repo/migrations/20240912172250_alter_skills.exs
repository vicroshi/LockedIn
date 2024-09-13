defmodule LockedIn.Repo.Migrations.AlterSkills do
  use Ecto.Migration

  def change do
    alter table(:skills) do
      remove :inserted_at, :utc_datetime
      remove :updated_at, :utc_datetime
    end
  end
end
