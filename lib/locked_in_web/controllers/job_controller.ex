defmodule LockedInWeb.JobController do
  use LockedInWeb, :controller

  alias LockedIn.Jobs.Job
  alias LockedIn.Jobs
  import LockedIn.Helpers
  action_fallback LockedInWeb.FallbackController

  def index(conn, _params) do
    jobs = conn.assigns.current_user |> with_assoc([:jobs]) |> Map.get(:jobs)
    render(conn, :index, jobs: jobs |> with_assoc([:user, :skills, :applications]))
  end

  def mark_viewed(conn, %{"job_id" => id}) do
    job = Jobs.get_job!(id) |> with_assoc([:user, :skills, :applications])
    case Jobs.mark_viewed(job.id,conn.assigns.current_user.id) do
      {1, _} -> conn
                |> put_status(:created)
                |> render(:show, job: Map.put(job,:viewed,true) |> IO.inspect())
      {0, _} -> json(conn, %{errors: "error creating view"})
    end
  end

  def create(conn, %{"job" => job_params}) do
    with {:ok, %Job{} = job} <- Jobs.create_job(conn.assigns.current_user.id,job_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", ~p"/api/jobs/#{job}")
      |> render(:show, job: job |> with_assoc([:user]))
    end
  end

  def show(conn, %{"job_id" => id}) do
    job = Jobs.get_job!(id)
    render(conn, :show, job: job |> with_assoc([:user, :skills, :applications])) end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Jobs.get_job!(id)

    with {:ok, %Job{} = job} <- Jobs.update_job(job, job_params) do
      render(conn, :show, job: job)
    end
  end

  def delete(conn, %{"job_id" => id}) do
    job = Jobs.get_job!(id)

    with {:ok, %Job{}} <- Jobs.delete_job(job) do
      send_resp(conn, :no_content, "")
    end
  end

  def feed(conn, _params) do
    jobs = Jobs.jobs_feed(conn.assigns.current_user.id)
    render(conn, :index, jobs: jobs |> with_assoc([:user, :skills]))
  end

end
