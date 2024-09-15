defmodule LockedIn.Repo.Migrations.AlterTableChats do
  use Ecto.Migration

  def change do
    rename table(:chats), :starter_id, to: :user1_id
    rename table(:chats), :chatter_id, to: :user2_id
    create unique_index(:chats, ["LEAST(user1_id, user2_id), GREATEST(user1_id, user2_id)"], name: :unique_user1_user2)
  end
end
