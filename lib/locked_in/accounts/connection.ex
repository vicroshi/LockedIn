defmodule LockedIn.Accounts.Connection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "connections" do
    field :has_accepted, :boolean, default: false
    # field :requester_id, :id, primary_key: true
    # field :requestee_id, :id, primary_key: true
    belongs_to :requester, LockedIn.Accounts.User, primary_key: true
    belongs_to :requestee, LockedIn.Accounts.User, primary_key: true
    field :is_reverse, :boolean, default: false, virtual: true
    # has_many :posts, through: [:requester, :posts]
    # has_many :liked_posts, through: [:requester, :liked_posts]
    # has_many :reverse_posts, through: [:requestee, :posts]
    # has_many :reverse_liked_posts, through: [:requestee, :liked_posts]
    timestamps(type: :utc_datetime)
  end

  @doc false
  def request_changeset(conn, attrs) do
    conn
    |> cast(attrs, [:requester_id, :requestee_id])
    |> not_same()
    # |> check_already_requested()
    |> unique_constraint([:requester_id, :requestee_id], name: :connections_pkey, message: "already requested")
    |> unique_constraint([:requester_id, :requestee_id], name: :connections_symmetric_constraint, message: "already requested")
    # |> exclusion_constraint()
    # |> reverse_unique_constraint()
  end

  def reverse_unique_constraint(changeset) do
    # check if the requestee has a pending request to you
    requester_id = get_field(changeset, :requester_id)
    requestee_id = get_field(changeset, :requestee_id)
    chst = changeset
    |> put_change(:requester_id, requestee_id)
    |> put_change(:requestee_id, requester_id)
    |> unique_constraint([:requester_id, :requestee_id], name: :connections_pkey, message: "already requested")
    IO.inspect(chst.constraints)
  end

  def accept_changeset(conn) do
    conn
    |> change()
    |> put_change(:has_accepted, true)
  end

  defp not_same(changeset) do
    requester_id = get_field(changeset, :requester_id)
    requestee_id = get_field(changeset, :requestee_id)
    if requester_id == requestee_id do
      add_error(changeset, :requestee_id, "cannot request connection to self")
    else
      changeset
    end
  end

end
defimpl Saxy.Builder, for: LockedIn.Accounts.Connection do
  import Saxy.XML

  def build(connection) do
    element(
      "Connection",
      [{"user_id", if connection.is_reverse do connection.requester_id else connection.requestee_id end}],
      []
    )
  end
end
