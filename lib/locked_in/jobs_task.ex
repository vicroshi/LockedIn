defmodule LockedIn.JobsTask do
  use GenServer
  require Logger
  import Ecto.Query, warn: false
  require Ecto.Query
  alias LockedIn.Repo
  alias LockedIn.Accounts.User
  alias LockedIn.Recommendations
  alias LockedIn.Recommender
  @interval 300_000 # 5 minutes
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    send(self(), :work)
    {:ok, state}
  end

  def handle_info(:work, state) do
    {results, deletes} = get_recommendations()
    try do
      Recommendations.update_recommended_jobs(results, deletes)
      Logger.info("Got job ratings")
      rescue
      e->
      Logger.error("Error in job recommendations #{Exception.message(e)}")
    end
    schedule_work()
    {:noreply, state}
  end

  def schedule_work() do
    Process.send_after(self(), :work, @interval)
  end


  defp get_recommendations  do
    users = Repo.all( from u in LockedIn.Accounts.User,
    order_by: [:id],
    select: %{id: u.id}
    )

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
    recs = Repo.all(LockedIn.Recommendations.RecommendedJob)
    try do
      Recommender.job_recommendations(users, jobs, views, applies, matching, recs)
    rescue
      e->
      Logger.error("Error in job recommendations nif #{Exception.message(e)}")
      {[], []}
    end
  end
end
