defmodule LockedIn.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do

      timestamps(type: :utc_datetime)
    end
  end
end
