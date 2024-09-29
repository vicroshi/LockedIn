defmodule LockedIn.Recommendations.RecommendedPost do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "recommended_posts" do
    field :rating, :float
    belongs_to :user, LockedIn.Accounts.User
    belongs_to :post, LockedIn.Blog.Post
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recommended_post, attrs) do
    recommended_post
    |> cast(attrs, [])
    |> validate_required([])
  end
end
