defmodule LockedIn.Recommendations.JobRating do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "job_ratings" do
    field :rating, :float
    belongs_to :user, LockedIn.Accounts.User
    belongs_to :job, LockedIn.Jobs.Job

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recommended_jobs, attrs) do
    recommended_jobs
    |> cast(attrs, [:rating])
    |> validate_required([:rating])
  end
end
