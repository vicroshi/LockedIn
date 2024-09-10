defmodule LockedIn.Posts.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :is_comment, :boolean, default: false
    field :is_read, :boolean, default: false
    belongs_to :sender, LockedIn.Accounts.User
    belongs_to :recipient, LockedIn.Accounts.User
    belongs_to :post, LockedIn.Posts.Post
    has_one :comment, {"comment_notifications", LockedIn.Posts.Comment}
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:is_comment])
    |> validate_required([:is_comment])
  end
end
