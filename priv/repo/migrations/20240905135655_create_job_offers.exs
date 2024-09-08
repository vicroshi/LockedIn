defmodule LockedIn.Repo.Migrations.CreateJobOffers do
  use Ecto.Migration

  def change do
    create table(:job_offers) do
      add :title, :string
      add :skills, {:array, :string}
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:job_offers, [:user_id])
  end
end
