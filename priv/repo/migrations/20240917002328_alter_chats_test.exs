defmodule LockedIn.Repo.Migrations.AlterChatsTest do
  use Ecto.Migration

  def change do
    drop constraint(:chats, :chats_chatter_id_fkey)
    drop constraint(:chats, :chats_starter_id_fkey)
    drop index("chats", [:chatter_id])
    drop index("chats", [:starter_id, :chatter_id])
    alter table(:chats) do
      modify :user1_id, references(:connections, column: :requester_id, with: [user2_id: :requestee_id ])
    end
  end
end
