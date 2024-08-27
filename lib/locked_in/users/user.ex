defmodule LockedIn.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :password, :string
    field :firstname, :string
    field :lastname, :string
    field :email, :string
    field :phone, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:firstname, :lastname, :email, :password, :phone])
    |> validate_required([:firstname, :lastname, :email, :password, :phone])
  end
end
