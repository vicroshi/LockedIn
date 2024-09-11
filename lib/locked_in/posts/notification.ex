defmodule LockedIn.Posts.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :is_read, :boolean, default: false
    belongs_to :sender, LockedIn.Accounts.User
    belongs_to :recipient, LockedIn.Accounts.User
    belongs_to :post, LockedIn.Posts.Post
    belongs_to :comment, LockedIn.Posts.Comment
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> validate_required([:sender_id, :recipient_id, :post_id])
    |> not_same_user()
  end
  def not_same_user(changeset) do
    sender_id = get_field(changeset, :sender_id)
    recipient_id = get_field(changeset, :recipient_id)
    if sender_id == recipient_id do
      add_error(changeset, :recipient_id, "can't be the same as sender")
    else
      changeset
    end
  end
end
