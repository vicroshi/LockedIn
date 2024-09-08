defmodule LockedIn.Repo.Migrations.CreateUserSkills do
  use Ecto.Migration

  def change do
    create table(:user_skills, primary_key: false) do
      add :public, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing), primary_key: true
      add :skill_id, references(:skills, on_delete: :nothing), primary_key: true

      timestamps(type: :utc_datetime)
    end
    create index(:user_skills, [:skill_id])
  end
end
