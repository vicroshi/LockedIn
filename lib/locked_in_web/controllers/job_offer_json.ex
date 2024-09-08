defmodule LockedInWeb.JobOfferJSON do
  alias LockedIn.Jobs.JobOffer

  @doc """
  Renders a list of job_offers.
  """
  def index(%{job_offers: job_offers}) do
    %{data: for(job_offer <- job_offers, do: data(job_offer))}
  end

  @doc """
  Renders a single job_offer.
  """
  def show(%{job_offer: job_offer}) do
    %{data: data(job_offer)}
  end

  defp data(%JobOffer{} = job_offer) do
    %{
      id: job_offer.id,
      title: job_offer.title,
      skills: job_offer.skills,
      description: job_offer.description
    }
  end
end
