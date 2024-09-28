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
  users = Repo.all(LockedIn.Accounts.User |> order_by(:id))
  jobs = Repo.all(
    from j in LockedIn.Jobs.Job,
    left_join: s in "job_skills",
    on: s.job_id == j.id,
    group_by: j.id,
    order_by: [:id],
    select: %{id: j.id, user_id: j.user_id, count: count(s.job_id)}
  )


  views = Repo.all(
    from v in "job_views",
    select: {v.user_id, v.job_id}
  )

  applies = Repo.all(
    from a in LockedIn.Jobs.Application,
    select: {a.applicant_id, a.job_id}
  )
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
  results = Recommender.job_recommendations(users, jobs, views, applies, matching)
  LockedIn.Recommendations.insert_ratings_jobs(results)
end

end
