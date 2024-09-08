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
  def changeset(user_skill, attrs) do
    user_skill
    |> cast(attrs, [:public])
  end
end
