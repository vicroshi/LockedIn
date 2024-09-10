defmodule LockedIn.Repo.Migrations.AddUniqueConstraintSkills do
  use Ecto.Migration

  def change do
    create unique_index(:skills, [:name])
  end
end
