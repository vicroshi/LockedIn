defmodule LockedIn.Repo.Migrations.AlterSomeFks do
  use Ecto.Migration

  def change do
    execute "drop table if exists applications cascade"
    create table(:applications) do
      add :cv, :string
      add :job_id, references(:jobs, on_delete: :delete_all)
      add :applicant_id, references(:users, on_delete: :delete_all)
      timestamps(type: :utc_datetime)
    end
    create index(:applications, [:applicant_id])
    create index(:applications, [:job_id])
  end
end
