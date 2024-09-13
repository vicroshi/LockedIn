defmodule LockedInWeb.ApplicationJSON do
  alias LockedIn.Jobs.Application

  @doc """
  Renders a list of applications.
  """
  def index(%{applications: applications}) do
    %{data: for(job_application <- applications, do: data(job_application))}
  end

  @doc """
  Renders a single job_application.
  """
  def show(%{job_application: job_application}) do
    %{data: data(job_application)}
  end

  defp data(%Application{} = job_application) do
    %{
      id: job_application.id,
      cv: job_application.cv
    }
  end
end
