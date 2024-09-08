defmodule LockedIn.Repo.Migrations.CreateJobSkills do
  use Ecto.Migration

  def change do
    create table(:job_skills, primary_key: false) do
      add :job_id, references(:job_offers, on_delete: :delete_all), primary_key: true
      add :skill_id, references(:skills, on_delete: :delete_all), primary_key: true
      timestamps()
    end

    create index(:job_skills, [:skill_id])
  end
end
