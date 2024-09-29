defmodule LockedIn.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias LockedIn.Accounts
  alias LockedIn.Accounts.Connection
  alias Ecto.Changeset
  alias LockedIn.Repo
  alias LockedIn.Jobs.{Job, Application}
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

  def mark_viewed(job_id, user_id) do
    Repo.insert_all("job_views", [%{job_id: job_id, user_id: user_id}], on_conflict: :nothing)
  end

  def list_jobs_by_user(user_id) do
    Repo.all(from(j in Job, where: j.user_id == ^user_id))
  end

  def jobs_feed(user_id, page) do
    connections_jobs_query =
      from j in Job,
        join: c in Connection,
        on: c.requestee_id == j.user_id and c.requester_id == ^user_id and c.has_accepted == true,
        left_join: v in "job_views",
        on: v.job_id == j.id and v.user_id == ^user_id,
        left_join: a in assoc(j, :applications),
        on: a.applicant_id == ^user_id,
        distinct: true,
        select: %{j | matching_skills: 0,
                      viewed: not is_nil(v.job_id),
                      applied: not is_nil(a.job_id)}
    reverse_connections_jobs_query =
      from j in Job,
        join: c in Connection,
        on: c.requester_id == j.user_id and c.requestee_id == ^user_id and c.has_accepted == true,
        left_join: v in "job_views",
        on: v.job_id == j.id and v.user_id == ^user_id,
        left_join: a in assoc(j, :applications),
        on: a.applicant_id == ^user_id,
        distinct: true,
        select: %{j | matching_skills: 0,
                      viewed: not is_nil(v.job_id),
                      applied: not is_nil(a.job_id)}
    # Repo.all(from j in subquery(connections_jobs_query |> union(^reverse_connections_jobs_query)),
              # order_by: [desc: j.inserted_at])
    skills_intersection_query =
      from j in Job,
        join: js in "job_skills",
        on: js.job_id == j.id,
        join: us in Accounts.UserSkill,
        on: us.skill_id == js.skill_id and us.public == true,
        left_join: v in "job_views",
        on: v.job_id == j.id and v.user_id == ^user_id,
        left_join: a in assoc(j, :applications),
        on: a.applicant_id == ^user_id,
        where: us.user_id == ^user_id,
        where: j.user_id != ^user_id,
        group_by: [j.id, v.job_id, a.job_id],
        select: %{j | matching_skills: count(js.skill_id),
                      viewed: not is_nil(v.job_id),
                      applied: not is_nil(a.job_id)}
        # select: j
    # connections_jobs = Repo.all(
    #   connections_jobs_query
    #   |> union_all(^reverse_connections_jobs_query))
    # skills_intersection = Repo.all skills_intersection_query
    # Enum.uniq_by(skills_intersection ++ connections_jobs, & &1.id)
    # |> Enum.sort_by(& &1.inserted_at,  {:desc, DateTime})
    # Repo.all(
    #   from
    # )
    jobs_with_matching_skills =
      from j in Job,
      left_join: js in "job_skills",
      on: js.job_id == j.id,
      left_join: us in Accounts.UserSkill,
      on: us.skill_id == js.skill_id and us.public == true and us.user_id == ^user_id,
      group_by: j.id,
      select: %{j | matching_skills: count(us.skill_id)}

    recommended_jobs =
      from rj in LockedIn.Recommendations.RecommendedJob,
      where: rj.user_id == ^user_id,
      select: %{id: rj.job_id}

    connections_jobs =
      from j in Job,
      join: c in LockedIn.Accounts.Connection,
      on: c.has_accepted == true and (c.requester_id == j.user_id and c.requestee_id == ^user_id or c.requestee_id == j.user_id and c.requester_id == ^user_id),
      select: %{id: j.id}

    feed_query =
      from j in subquery(jobs_with_matching_skills),
      preload: [:skills, :user],
      left_join: v in "job_views",
      on: v.job_id == j.id and v.user_id == ^user_id,
      left_join: a in Application,
      on: a.job_id == j.id and a.applicant_id == ^user_id,
      left_join: rj in LockedIn.Recommendations.RecommendedJob,
      on: rj.job_id == j.id and rj.user_id == ^user_id,
      where: j.user_id != ^user_id,
      where: j.id in subquery(recommended_jobs),
      or_where: j.id in subquery(connections_jobs),
      select: %{j | viewed: not is_nil(v.job_id), applied: not is_nil(a.job_id), recommended: not is_nil(rj.job_id)}

    params = %{page: page, page_size: 10, order_by: [:inserted_at, :id], order_directions: [:desc, :desc]}
    # {atom, {feed, meta}} =
      Flop.validate_and_run(feed_query, params)
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
  Gets a single application.

  Raises `Ecto.NoResultsError` if the Job application does not exist.

  ## Examples

      iex> get_application!(123)
      %Application{}

      iex> get_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_application!(id), do: Repo.get!(Application, id)

  @doc """
  Creates a application.

  ## Examples

      iex> create_application(%{field: value})
      {:ok, %Application{}}

      iex> create_application(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_application(user_id,attrs \\ %{}) do
    %Application{applicant_id: user_id}
    |> Application.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a application.

  ## Examples

      iex> update_application(application, %{field: new_value})
      {:ok, %Application{}}

      iex> update_application(application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_application(%Application{} = application, attrs) do
    application
    |> Application.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a application.

  ## Examples

      iex> delete_application(application)
      {:ok, %Application{}}

      iex> delete_application(application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_application(%Application{} = application) do
    Repo.delete(application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking application changes.

  ## Examples

      iex> change_application(application)
      %Ecto.Changeset{data: %Application{}}

  """
  def change_application(%Application{} = application, attrs \\ %{}) do
    Application.changeset(application, attrs)
  end
end
