defmodule LockedIn.Repo.Migrations.CreateCommentNotifications do
  use Ecto.Migration

  def change do
    create table(:comment_notifications, primary_key: false) do
      add :comment_id, references(:comments, on_delete: :delete_all), primary_key: true
      add :notification_id, references(:notifications, on_delete: :nothing), primary_key: true
    end
    create index(:comment_notifications, [:notification_id])
  end
end
