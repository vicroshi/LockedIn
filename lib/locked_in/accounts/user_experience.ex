defmodule LockedIn.Accounts.UserExperience do
  use Ecto.Schema
  import Ecto.Changeset
  # @primary_key {:id, :id, autogenerate: true}
  @derive {Jason.Encoder, except: []}
  @primary_key false
  embedded_schema do
    field :title, :string
    field :description, :string, default: nil
    field :company, :string
    field :start_date, :date
    field :end_date, :string, default: nil
    field :public , :boolean, default: false
  end

  @doc false
  def changeset(user_experience, attrs) do
    user_experience
    |> cast(attrs, [:title,:company, :start_date, :end_date, :public])
    |> validate_required([:title,:company, :start_date])
  end

end

defimpl Saxy.Builder, for: LockedIn.Accounts.UserExperience  do
  import Saxy.XML
  def build(user_experience) do
    element(
      "Experience",
      [id: user_experience.id],
      [
        element("Title",[], user_experience.title),
        element("Company",[], user_experience.company),
        element("StartDate",[], user_experience.start_date),
        element("EndDate",[], user_experience.end_date),
        element("Public",[], user_experience.public)
      ]
    )
  end
end
