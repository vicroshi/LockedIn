defmodule LockedIn.Repo.Migrations.AlterChatsFk do
  use Ecto.Migration

  def change do
    alter table(:chats) do
      modify :user1_id, references(:connections, column: :requester_id, with: [user2_id: :requestee_id ], on_delete: :delete_all), from: references(:connections, column: :requester_id, with: [user2_id: :requestee_id ])
    end
  end
end
