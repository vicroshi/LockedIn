defmodule LockedIn.Repo.Migrations.CreateJobApplications do
  use Ecto.Migration

  def change do
    create table(:job_applications) do
      add :cv, :string
      add :applicant_id, references(:users, on_delete: :nothing)
      add :job_id, references(:job_offers, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:job_applications, [:applicant_id])
    create index(:job_applications, [:job_id])
  end
end
