defmodule LockedIn.Repo.Migrations.AddEmbedsToUsers do
  use Ecto.Migration

  def change do
    alter table :users do
      add :experience, :map
      add :education, :map
    end
  end
end
