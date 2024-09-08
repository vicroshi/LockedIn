defmodule LockedIn.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias LockedIn.Repo

  alias LockedIn.Jobs.JobOffer

  @doc """
  Returns the list of job_offers.

  ## Examples

      iex> list_job_offers()
      [%JobOffer{}, ...]

  """
  def list_job_offers do
    Repo.all(JobOffer)
  end

  @doc """
  Gets a single job_offer.

  Raises `Ecto.NoResultsError` if the Job offer does not exist.

  ## Examples

      iex> get_job_offer!(123)
      %JobOffer{}

      iex> get_job_offer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_offer!(id), do: Repo.get!(JobOffer, id)

  @doc """
  Creates a job_offer.

  ## Examples

      iex> create_job_offer(%{field: value})
      {:ok, %JobOffer{}}

      iex> create_job_offer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_offer(attrs \\ %{}) do
    %JobOffer{}
    |> JobOffer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_offer.

  ## Examples

      iex> update_job_offer(job_offer, %{field: new_value})
      {:ok, %JobOffer{}}

      iex> update_job_offer(job_offer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_offer(%JobOffer{} = job_offer, attrs) do
    job_offer
    |> JobOffer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job_offer.

  ## Examples

      iex> delete_job_offer(job_offer)
      {:ok, %JobOffer{}}

      iex> delete_job_offer(job_offer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_offer(%JobOffer{} = job_offer) do
    Repo.delete(job_offer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_offer changes.

  ## Examples

      iex> change_job_offer(job_offer)
      %Ecto.Changeset{data: %JobOffer{}}

  """
  def change_job_offer(%JobOffer{} = job_offer, attrs \\ %{}) do
    JobOffer.changeset(job_offer, attrs)
  end

  alias LockedIn.Jobs.JobApplication

  @doc """
  Returns the list of job_applications.

  ## Examples

      iex> list_job_applications()
      [%JobApplication{}, ...]

  """
  def list_job_applications do
    Repo.all(JobApplication)
  end

  @doc """
  Gets a single job_application.

  Raises `Ecto.NoResultsError` if the Job application does not exist.

  ## Examples

      iex> get_job_application!(123)
      %JobApplication{}

      iex> get_job_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_application!(id), do: Repo.get!(JobApplication, id)

  @doc """
  Creates a job_application.

  ## Examples

      iex> create_job_application(%{field: value})
      {:ok, %JobApplication{}}

      iex> create_job_application(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_application(attrs \\ %{}) do
    %JobApplication{}
    |> JobApplication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_application.

  ## Examples

      iex> update_job_application(job_application, %{field: new_value})
      {:ok, %JobApplication{}}

      iex> update_job_application(job_application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_application(%JobApplication{} = job_application, attrs) do
    job_application
    |> JobApplication.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job_application.

  ## Examples

      iex> delete_job_application(job_application)
      {:ok, %JobApplication{}}

      iex> delete_job_application(job_application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_application(%JobApplication{} = job_application) do
    Repo.delete(job_application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_application changes.

  ## Examples

      iex> change_job_application(job_application)
      %Ecto.Changeset{data: %JobApplication{}}

  """
  def change_job_application(%JobApplication{} = job_application, attrs \\ %{}) do
    JobApplication.changeset(job_application, attrs)
  end
end
