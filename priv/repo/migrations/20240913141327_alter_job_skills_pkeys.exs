defmodule LockedIn.Repo.Migrations.AlterJobSkillsPkeys do
  use Ecto.Migration

  def change do
    drop table(:job_skills)
    create table(:job_skills, primary_key: false) do
      add :job_id, references(:jobs, on_delete: :delete_all), primary_key: true
      add :skill_id, references(:skills, on_delete: :delete_all), primary_key: true
    end
  end
end
