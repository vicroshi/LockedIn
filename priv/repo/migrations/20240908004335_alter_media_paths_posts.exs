defmodule LockedIn.Repo.Migrations.AlterMediaPathsPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :media_paths, {:array, :string}
      remove :media_path
    end
  end
end
