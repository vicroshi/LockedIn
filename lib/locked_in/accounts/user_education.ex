defmodule LockedIn.Accounts.UserEducation do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :school, :string
    field :degree, :string
    field :field_of_study, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime, default: nil
    field :public , :boolean, default: false
  end

  @doc false
  def changeset(user_education, attrs) do
    user_education
    |> cast(attrs, [:school, :degree, :field_of_study, :start_date, :end_date, :public])
    |> validate_required([:school, :degree, :field_of_study, :start_date])
  end

end
