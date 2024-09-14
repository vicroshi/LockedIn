defmodule LockedIn.Repo.Migrations.AlterUsersPfp do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :pfp, :string, null: true
    end
  end
end
