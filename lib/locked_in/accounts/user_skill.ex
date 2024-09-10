defmodule LockedIn.Accounts.UserSkill do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "user_skills" do
    field :public, :boolean, default: true
    belongs_to :user, LockedIn.Accounts.User, primary_key: true
    belongs_to :skill, LockedIn.Skills.Skill, primary_key: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(struct, attrs) do
    IO.inspect(attrs)
    struct
    |> cast(attrs, [:user_id, :skill_id, :public])
    |> validate_required([:user_id, :skill_id])

  end
  def user_skill_changeset(changeset,attrs) do
    # %__MODULE__{}
    # |> cast(attrs, [:public])
  end
end
