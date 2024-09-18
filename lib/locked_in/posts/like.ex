defmodule LockedIn.Posts.Like do
  use Ecto.Schema
  import Ecto.Changeset
  alias LockedIn.Posts.Post
  alias LockedIn.Accounts.User
  @derive {Saxy.Builder, name: "like", attributes: [:post_id]}
  @primary_key false
  schema "likes" do

    belongs_to :user, User, primary_key: true
    belongs_to :post, Post, primary_key: true

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(like) do
    Ecto.Changeset.change(like)
    # |> cast(attrs, [post_id: :integer, user_id: :integer])
    # |> validate_required([])
    |> unique_constraint([:user_id, :post_id], name: :likes_pkey, message: "already liked")
  end
end
