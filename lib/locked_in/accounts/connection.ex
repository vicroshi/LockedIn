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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def request_changeset(conn, attrs) do
    conn
    |> cast(attrs, [:requester_id, :requestee_id])
    |> not_same()
    |> unique_constraint([:requester_id, :requestee_id], name: :connections_pkey, message: "already requested")
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
