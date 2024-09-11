defmodule LockedIn.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :media, :any, virtual: true
    field :media_paths, {:array, :string}, default: []
    field :like_count , :integer, virtual: true
    field :comment_count , :integer, virtual: true
    belongs_to :user, LockedIn.Accounts.User
    has_many :likes, LockedIn.Posts.Like
    has_many :users_liked, through: [:likes, :user]
    has_many :comments, LockedIn.Posts.Comment
    has_one :notification, LockedIn.Posts.Notification
    timestamps(type: :utc_datetime, inserted_at: :posted_at, inserted_at_source: :inserted_at)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :media_paths, :user_id])
    |> validate_required([:content, :user_id])
  end
end
