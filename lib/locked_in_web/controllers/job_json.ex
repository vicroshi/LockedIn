defmodule LockedInWeb.JobJSON do
  alias LockedIn.Jobs.Job

  @doc """
  Renders a list of jobs.
  """
  def index(%{jobs: jobs}) do
    %{data: for(job_offer <- jobs, do: data(job_offer))}
  end

  @doc """
  Renders a single job_offer.
  """
  def show(%{job_offer: job_offer}) do
    %{data: data(job_offer)}
  end

  defp data(%Job{} = job_offer) do
    %{
      id: job_offer.id,
      title: job_offer.title,
      skills: job_offer.skills,
      description: job_offer.description
    }
  end
end
