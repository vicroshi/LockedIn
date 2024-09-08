defmodule LockedInWeb.JobOfferController do
  use LockedInWeb, :controller

  alias LockedIn.Jobs
  alias LockedIn.Jobs.JobOffer

  action_fallback LockedInWeb.FallbackController

  def index(conn, _params) do
    job_offers = Jobs.list_job_offers()
    render(conn, :index, job_offers: job_offers)
  end

  def create(conn, %{"job_offer" => job_offer_params}) do
    with {:ok, %JobOffer{} = job_offer} <- Jobs.create_job_offer(job_offer_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/job_offers/#{job_offer}")
      |> render(:show, job_offer: job_offer)
    end
  end

  def show(conn, %{"id" => id}) do
    job_offer = Jobs.get_job_offer!(id)
    render(conn, :show, job_offer: job_offer)
  end

  def update(conn, %{"id" => id, "job_offer" => job_offer_params}) do
    job_offer = Jobs.get_job_offer!(id)

    with {:ok, %JobOffer{} = job_offer} <- Jobs.update_job_offer(job_offer, job_offer_params) do
      render(conn, :show, job_offer: job_offer)
    end
  end

  def delete(conn, %{"id" => id}) do
    job_offer = Jobs.get_job_offer!(id)

    with {:ok, %JobOffer{}} <- Jobs.delete_job_offer(job_offer) do
      send_resp(conn, :no_content, "")
    end
  end
end
