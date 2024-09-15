defmodule LockedIn.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :is_read, :boolean, default: false
    belongs_to :sender, LockedIn.Accounts.User
    belongs_to :receiver, LockedIn.Accounts.User
    belongs_to :chat, LockedIn.Chats.Chat
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :receiver_id, :sender_id])
    |> validate_required([:sender_id, :chat_id, :receiver_id, :content])
  end
end
