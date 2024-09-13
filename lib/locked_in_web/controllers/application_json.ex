defmodule LockedInWeb.ApplicationJSON do
  alias LockedIn.Jobs.Application


  def index(%{applications: applications = %Ecto.Association.NotLoaded{}}) do
    []
  end

  @doc """
  Renders a list of applications.
  """
  def index(%{applications: applications}) do
    %{data: for(application <- applications, do: data(application))}
  end

  @doc """
  Renders a single application.
  """
  def show(%{application: application}) do
    %{data: data(application)}
  end

  defp data(%Application{} = application) do
    %{
      user_id: application.applicant_id,
      user_fname: application.applicant.firstname,
      user_lname: application.applicant.lastname,
      job_id: application.job_id
    }
  end
end
