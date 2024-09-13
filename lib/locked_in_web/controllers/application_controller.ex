defmodule LockedInWeb.ApplicationController do
  use LockedInWeb, :controller

  alias LockedIn.Jobs
  alias LockedIn.Jobs.Application
  import LockedIn.Helpers
  action_fallback LockedInWeb.FallbackController

  def index(conn, _params) do
    applications = Jobs.list_applications()
    render(conn, :index, applications: applications)
  end

  def create(conn, %{"job_id" => job_id}= params) do
    with {:ok, %Application{} = application} <- Jobs.create_application(conn.assigns.current_user.id,params) do
      conn
      |> put_status(:created)
      |> render(:show, application: application |> with_assoc(:applicant))
    end
  end

  def show(conn, %{"id" => id}) do
    application = Jobs.get_application!(id)
    render(conn, :show, application: application)
  end

  def update(conn, %{"id" => id, "application" => application_params}) do
    application = Jobs.get_application!(id)

    with {:ok, %Application{} = application} <- Jobs.update_application(application, application_params) do
      render(conn, :show, application: application)
    end
  end

  def delete(conn, %{"id" => id}) do
    application = Jobs.get_application!(id)

    with {:ok, %Application{}} <- Jobs.delete_application(application) do
      send_resp(conn, :no_content, "")
    end
  end
end
