defmodule LockedIn.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :media, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :media])
    |> validate_required([:content, :media])
  end
end
