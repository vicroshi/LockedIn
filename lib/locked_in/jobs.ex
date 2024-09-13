defmodule LockedIn.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias LockedIn.Repo

  alias LockedIn.Jobs.Job
  alias LockedIn.Skills
  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job offer does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(user_id, attrs \\ %{}) do
    # user
    %Job{}
    # |> Ecto.build_assoc(:jobs, attrs)
    # |> Repo.preload(:skills)
    |> Job.changeset(Map.put(attrs, "user_id", user_id))
    |> Changeset.put_assoc(:skills, Skills.insert_and_get_all_skills(attrs["skills"]))
    |> IO.inspect()
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  alias LockedIn.Jobs.Application

  @doc """
  Returns the list of applications.

  ## Examples

      iex> list_applications()
      [%Application{}, ...]

  """
  def list_applications do
    Repo.all(Application)
  end

  @doc """
  Gets a single job_application.

  Raises `Ecto.NoResultsError` if the Job application does not exist.

  ## Examples

      iex> get_job_application!(123)
      %Application{}

      iex> get_job_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_application!(id), do: Repo.get!(Application, id)

  @doc """
  Creates a job_application.

  ## Examples

      iex> create_job_application(%{field: value})
      {:ok, %Application{}}

      iex> create_job_application(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_application(attrs \\ %{}) do
    %Application{}
    |> Application.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_application.

  ## Examples

      iex> update_job_application(job_application, %{field: new_value})
      {:ok, %Application{}}

      iex> update_job_application(job_application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_application(%Application{} = job_application, attrs) do
    job_application
    |> Application.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job_application.

  ## Examples

      iex> delete_job_application(job_application)
      {:ok, %Application{}}

      iex> delete_job_application(job_application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_application(%Application{} = job_application) do
    Repo.delete(job_application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_application changes.

  ## Examples

      iex> change_job_application(job_application)
      %Ecto.Changeset{data: %Application{}}

  """
  def change_job_application(%Application{} = job_application, attrs \\ %{}) do
    Application.changeset(job_application, attrs)
  end
end
