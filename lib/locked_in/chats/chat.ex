defmodule LockedIn.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    belongs_to :user1, LockedIn.Accounts.User
    belongs_to :user2, LockedIn.Accounts.User
    has_many :messages, LockedIn.Chats.Message, preload_order: [desc: :inserted_at]
    has_one :latest_message,
    LockedIn.Chats.Message,
    where: [chat_id:
    {:fragment, "(m0.\"inserted_at\") = (SELECT MAX(\"messages\".inserted_at) FROM messages WHERE \"messages\".chat_id = ?)"}]
    # timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:user1_id, :user2_id])
    |> validate_required([:user1_id, :user2_id])
    |> foreign_key_constraint(:user1_id)
    |> foreign_key_constraint(:user2_id)
    |> unique_constraint([:user1_id, :user2_id], name: :chats_pkey)
    |> unique_constraint([:user1_id, :user2_id], name: :unique_user1_user2)
  end
end
