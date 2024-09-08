defmodule LockedInWeb.JobApplicationJSON do
  alias LockedIn.Jobs.JobApplication

  @doc """
  Renders a list of job_applications.
  """
  def index(%{job_applications: job_applications}) do
    %{data: for(job_application <- job_applications, do: data(job_application))}
  end

  @doc """
  Renders a single job_application.
  """
  def show(%{job_application: job_application}) do
    %{data: data(job_application)}
  end

  defp data(%JobApplication{} = job_application) do
    %{
      id: job_application.id,
      cv: job_application.cv
    }
  end
end
