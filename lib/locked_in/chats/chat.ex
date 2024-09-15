defmodule LockedIn.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    belongs_to :starter, LockedIn.Accounts.User 
    belongs_to :chatter, LockedIn.Accounts.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [])
    |> validate_required([])
  end
end
