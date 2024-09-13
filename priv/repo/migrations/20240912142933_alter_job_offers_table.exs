defmodule LockedIn.Repo.Migrations.AlterJobsTable do
  use Ecto.Migration

  def change do
    execute "drop table if exists job_offers cascade"
    create table(:jobs) do
      add :description, :string
      add :position, :string
      add :company_name, :string
      add :location, :string
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps(type: :date, updated_at: false)
    end
    create index(:jobs, [:user_id])
    # create index(:jobs, [:position])
    # create
  end
end
