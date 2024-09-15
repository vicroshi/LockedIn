defmodule LockedIn.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :is_read, :boolean, default: false
    belongs_to :sender, LockedIn.Accounts.User
    belongs_to :receiver, LockedIn.Accounts.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:sender_id, :receiver_id, :content])
  end
end
