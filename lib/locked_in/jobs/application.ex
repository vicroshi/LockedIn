defmodule LockedIn.Jobs.Application do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "applications" do
    field :cv, :string
    belongs_to :applicant, LockedIn.Accounts.User, primary_key: true
    belongs_to :job, LockedIn.Jobs.Job, primary_key: true
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(job_application, attrs) do
    job_application
    |> cast(attrs, [:cv])
    |> validate_required([:cv])
  end
end
