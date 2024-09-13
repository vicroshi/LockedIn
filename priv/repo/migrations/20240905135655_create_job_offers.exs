defmodule LockedIn.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string
      add :skills, {:array, :string}
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:jobs, [:user_id])
  end
end
