defmodule LockedIn.Skills.Skill do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, only: [:name, :id]}
  @derive {Saxy.Builder, name: "skill", attributes: [:id], children: [:name]}
  schema "skills" do
    field :name, :string
    many_to_many :users, LockedIn.Accounts.User, join_through: "user_skills"
    field :public , :boolean, default: true, virtual: true
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name, :public])
    |> unique_constraint(:name, name: :skills_name_index)
    |> validate_required([:name])
  end

  def set_public(skill, public) do
    skill
    |> change
    |> put_change(:public, public)
  end

  def user_skill_changeset(attrs) do
    # %UserSkill{}
    # |> cast(attrs, [:public])
  end

end
