defmodule LockedIn.Helpers do
  import Ecto.Query, warn: false
  alias LockedIn.Recommender
  alias LockedIn.Repo

  def with_assoc(struct, assocs) do
    Repo.preload(struct, assocs)
  end


  def sanitize(str) do
    # IO.inspect(str)
    replace_ampersand(str)
    # {:safe, iosafe} = Phoenix.HTML.html_escape(str)
    # IO.iodata_to_binary(iosafe)
  end

  def replace_ampersand(str) do
    String.replace(str, "&", "and")
  end

require Ecto.Query
def test_recommender do
  users = Repo.all(LockedIn.Accounts.User |> limit(10))
  jobs = Repo.all(LockedIn.Jobs.Job |> limit(5))
  views = Repo.all(
    from u in LockedIn.Accounts.User,
    join: v in "job_views",
    on: v.user_id == u.id,
    join: j in LockedIn.Jobs.Job,
    on: v.job_id == j.id,
    group_by: [u.id, j.id],
    select: %{user_id: u.id, job_id: j.id}
  )
  |> Enum.map(fn %{user_id: user_id, job_id: job_id} -> {user_id, job_id} end)
  applies = Repo.all(
    from u in LockedIn.Accounts.User,
    join: a in LockedIn.Jobs.Application,
    on: a.applicant_id == u.id,
    join: j in LockedIn.Jobs.Job,
    on: a.job_id == j.id,
    group_by: [u.id, j.id],
    select: %{user_id: u.id, job_id: j.id}
  ) |> Enum.map(fn %{user_id: user_id, job_id: job_id} -> {user_id, job_id} end)

  matching = Repo.all(
    from u in LockedIn.Accounts.User,
    join: us in "user_skills",
    on: us.user_id == u.id,
    join: s in LockedIn.Skills.Skill,
    on: us.skill_id == s.id,
    join: js in "job_skills",
    on: js.skill_id == s.id,
    join: j in LockedIn.Jobs.Job,
    on: js.job_id == j.id,
    group_by: [u.id, j.id],
    select: %{user_id: u.id, job_id: j.id, count: count(s.id)}
  )
  # |>
  # IO.inspect()
  # users_map = users|>Enum.with_index()|>Enum.map( fn {v, k} -> {k, %LockedIn.Accounts.User{id: v.id}} end)
  Recommender.construct_job_matrix(users, jobs, views, applies, matching)
  # users = Enum.with_index(Repo.all(LockedIn.Accounts.User |> limit(10)), fn user, index ->
    # {index, user}
  # end)
  # Enum.at(users, 0)
end

end
