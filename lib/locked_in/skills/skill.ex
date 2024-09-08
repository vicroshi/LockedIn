defmodule LockedIn.Skills.Skill do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, only: [:name, :id]}
  schema "skills" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def user_skill_changeset(attrs) do
    # %UserSkill{}
    # |> cast(attrs, [:public])
  end

end
