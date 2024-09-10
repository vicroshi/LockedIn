defmodule LockedIn.Accounts.UserExperience do
  use Ecto.Schema
  import Ecto.Changeset
  # @primary_key {:id, :id, autogenerate: true}
  embedded_schema do
    field :title, :string
    field :description, :string, default: nil
    field :company, :string
    field :start_date, :date
    field :end_date, :date, default: nil
    field :public , :boolean, default: false
  end

  @doc false
  def changeset(user_experience, attrs) do
    user_experience
    |> cast(attrs, [:title,:company, :start_date, :end_date, :public])
    |> validate_required([:title,:company, :start_date])
  end

end
