defmodule LockedIn.Posts.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Saxy.Builder, name: "comment", attributes: [:id], children: [:content]}
  schema "comments" do
    field :content, :string
    belongs_to :user, LockedIn.Accounts.User
    belongs_to :post, LockedIn.Posts.Post
    has_one :notification, LockedIn.Accounts.Notification
    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
