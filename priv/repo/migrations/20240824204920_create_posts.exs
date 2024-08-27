defmodule LockedIn.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :content, :text
      add :media, :string
      timestamps(type: :utc_datetime)
    end
  end
end
