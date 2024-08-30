defmodule LockedIn.Repo.Migrations.AlterTablePosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :media_path, :string, null: true
      add :user_id, references(:users, on_delete: :delete_all)
      remove :media
    end
    create index(:posts, [:user_id])
  end
end
