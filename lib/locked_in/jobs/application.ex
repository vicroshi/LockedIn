defmodule LockedIn.Jobs.Application do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "applications" do
    field :cv, :string, default: nil
    belongs_to :applicant, LockedIn.Accounts.User, primary_key: true
    belongs_to :job, LockedIn.Jobs.Job, primary_key: true
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [:applicant_id, :job_id])
    |> validate_required([:applicant_id, :job_id])
  end

  def not_same(application, user_id) do
    if application.applicant_id == user_id do
      change(application)
      |> add_error(:applicant_id, "cannot apply to own job")
    else
      application
    end
  end

end
