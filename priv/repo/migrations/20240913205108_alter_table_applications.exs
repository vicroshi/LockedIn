defmodule LockedIn.Repo.Migrations.AlterTableApplications do
  use Ecto.Migration

  def up do

    drop table(:applications)

    create table(:applications, primary_key: false) do
      add :cv, :string, null: true
      add :applicant_id, references(:users, on_delete: :delete_all), primary_key: true
      add :job_id, references(:jobs, on_delete: :delete_all), primary_key: true

      timestamps(type: :utc_datetime)
    end
  end

  def down do
    drop table(:applications)
  end

end
