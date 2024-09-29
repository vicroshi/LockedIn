defmodule LockedIn.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :description, :position, :company_name, :location, :user_id]}
  schema "jobs" do
    field :description, :string
    field :position, :string
    field :company_name, :string
    field :location, :string
    field :viewed, :boolean, default: false, virtual: true
    field :applied, :boolean, default: false, virtual: true
    field :recommended, :boolean, default: false, virtual: true
    many_to_many :skills, LockedIn.Skills.Skill, join_through: "job_skills", on_replace: :delete
    belongs_to :user, LockedIn.Accounts.User
    has_many :applications, LockedIn.Jobs.Application, foreign_key: :job_id
    field :matching_skills, :integer, virtual: true, default: nil
    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(job_offer, attrs) do
    job_offer
    |> cast(attrs, [:user_id,:position,:company_name, :location, :description])
    |> validate_required([:position, :location, :company_name])
  end
end

defimpl Saxy.Builder, for: LockedIn.Jobs.Job do
  import Saxy.XML

  def build(job) do
    element(
      "Job",
      [id: job.id],
      [
        element("Position",[], LockedIn.Helpers.sanitize(job.position)),
        element("CompanyName",[], LockedIn.Helpers.sanitize(job.company_name)),
        element("Location",[], LockedIn.Helpers.sanitize(job.location)),
        element("Description",[], LockedIn.Helpers.sanitize(job.description)),
        element("Skills",[], job.skills),
      ]
    )

  end
end
