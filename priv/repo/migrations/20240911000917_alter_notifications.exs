defmodule LockedIn.Repo.Migrations.AlterNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      remove :is_comment, :boolean, default: false, null: false
      add :comment_id, references(:comments, on_delete: :delete_all), null: true
    end
  end
end
