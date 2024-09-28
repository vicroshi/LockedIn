defmodule LockedIn.Accounts.UserEducation do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: []}

  @primary_key false

  embedded_schema do
    field :school, :string
    field :degree, :string
    field :field_of_study, :string
    field :start_date, :date
    field :end_date, :string, default: nil
    field :public , :boolean, default: false
  end

  @doc false
  def changeset(user_education, attrs) do
    user_education
    |> cast(attrs, [:school, :degree, :field_of_study, :start_date, :end_date, :public])
    |> validate_required([:school, :degree, :start_date])
  end

end

defimpl Saxy.Builder, for: LockedIn.Accounts.UserEducation  do
  import Saxy.XML
  def build(user_education) do
    element(
      "Education",
      [],
      [
        element("Degree",[], LockedIn.Helpers.sanitize(user_education.degree)),
        element("School",[], LockedIn.Helpers.sanitize(user_education.school)),
        # element("School",[], user_education.school),
        element("StartDate",[], user_education.start_date),
        element("EndDate",[], user_education.end_date),
        element("Public",[], user_education.public)
      ]
    )
  end
end
