defmodule LockedIn.Accounts.UserExperience do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string
    field :description, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime, default: nil
    field :public , :boolean, default: false
  end

  @doc false
  def changeset(user_experience, attrs) do
    user_experience
    |> cast(attrs, [:title, :description, :start_date, :end_date, :public])
    |> validate_required([:title, :start_date])
  end

end
