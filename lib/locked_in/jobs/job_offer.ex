defmodule LockedIn.Jobs.JobOffer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_offers" do
    field :description, :string
    field :title, :string
    many_to_many :skills, LockedIn.Skills.Skill, join_through: "job_skills"
    belongs_to :user, LockedIn.Accounts.User
    has_many :applications, LockedIn.Jobs.JobApplication, foreign_key: :job_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(job_offer, attrs) do
    job_offer
    |> cast(attrs, [:title, :skills, :description])
    |> validate_required([:title, :skills, :description])
  end
end
