defmodule LockedIn.Repo.Migrations.AddJobSkillFk do
  use Ecto.Migration

  def change do
    alter table(:job_skills) do
      remove :job_id
      add :job_id, references(:jobs, on_delete: :delete_all)
    end
  end
end
