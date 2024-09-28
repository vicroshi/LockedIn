defmodule LockedIn.Repo.Migrations.CreateRecommendedJobs do
  use Ecto.Migration

  def change do
    create table(:job_ratings, primary_key: false) do
      add :rating, :float
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :job_id, references(:jobs, on_delete: :delete_all), primary_key: true

      timestamps(type: :utc_datetime)
    end

    create index(:job_ratings, [:job_id])
  end
end
