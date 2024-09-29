defmodule LockedIn.PostsTask do
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
    # |>IO.inspect()
    Recommendations.update_recommended_posts(results, deletes)
    Logger.info("Got post ratings")
    schedule_work()
    {:noreply, state}
  end

  def schedule_work() do
    Process.send_after(self(), :work, @interval)
  end


  defp get_recommendations  do
    users = Repo.all(
      from u in LockedIn.Accounts.User,
      order_by: [:id],
      select: %{id: u.id}
      )
    posts = Repo.all(
      from p in LockedIn.Posts.Post,
      order_by: [:id],
      select: %{id: p.id, user_id: p.user_id}
    )


    views = Repo.all(
      from v in "post_views",
      select: {v.user_id, v.post_id}
    )

    likes = Repo.all(
      from l in LockedIn.Posts.Like,
      select: {l.user_id, l.post_id}
    )
    comments = Repo.all(
      from c in LockedIn.Posts.Comment,
      group_by: [c.user_id, c.post_id],
      select: {c.user_id, c.post_id}
    )

    recs = Repo.all(
      from rp in LockedIn.Recommendations.RecommendedPost,
      select: %{user_id: rp.user_id, post_id: rp.post_id,rating: rp.rating}

      )
    # IO.inspect(recs, label: "Recommended Posts")
    Recommender.post_recommendations(users, posts, views, likes, comments, recs)
  end
end
