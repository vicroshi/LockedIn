defmodule LockedInWeb.JobApplicationController do
  use LockedInWeb, :controller

  alias LockedIn.Jobs
  alias LockedIn.Jobs.JobApplication

  action_fallback LockedInWeb.FallbackController

  def index(conn, _params) do
    job_applications = Jobs.list_job_applications()
    render(conn, :index, job_applications: job_applications)
  end

  def create(conn, %{"job_application" => job_application_params}) do
    with {:ok, %JobApplication{} = job_application} <- Jobs.create_job_application(job_application_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/job_applications/#{job_application}")
      |> render(:show, job_application: job_application)
    end
  end

  def show(conn, %{"id" => id}) do
    job_application = Jobs.get_job_application!(id)
    render(conn, :show, job_application: job_application)
  end

  def update(conn, %{"id" => id, "job_application" => job_application_params}) do
    job_application = Jobs.get_job_application!(id)

    with {:ok, %JobApplication{} = job_application} <- Jobs.update_job_application(job_application, job_application_params) do
      render(conn, :show, job_application: job_application)
    end
  end

  def delete(conn, %{"id" => id}) do
    job_application = Jobs.get_job_application!(id)

    with {:ok, %JobApplication{}} <- Jobs.delete_job_application(job_application) do
      send_resp(conn, :no_content, "")
    end
  end
end
