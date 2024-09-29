defmodule LockedIn.Recommendations do

  import Ecto.Query, warn: false
  alias LockedIn.Repo
  alias LockedIn.Recommendations.{RecommendedJob, RecommendedPost}

  def update_recommended_jobs(inserts,deletes) do
    tups = Enum.map(deletes, fn d -> {d.user_id, d.job_id} end)
    dels = Enum.join(for({uid, jid} <- tups, do: "(#{uid}, #{jid})"), ", ")
    if length(deletes) > 0 do
      Repo.query("DELETE FROM recommended_jobs WHERE (user_id, job_id) IN (#{dels})")
    end
    timestamp =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    placeholders = %{timestamp: timestamp}
    Enum.map(inserts, fn r ->
      %{user_id: r.user_id, job_id: r.job_id, rating: r.rating,
      inserted_at: {:placeholder,  :timestamp}, updated_at: {:placeholder,  :timestamp}}
    end)
    |>
    Enum.chunk_every(2000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(RecommendedJob, chunk, placeholders: placeholders,  on_conflict: :replace_all, conflict_target: [:user_id, :job_id])
    end)
  end

  def update_recommended_posts(inserts,deletes) do
    tups = Enum.map(deletes, fn d -> {d.user_id, d.post_id} end)
    dels = Enum.join(for({uid, pid} <- tups, do: "(#{uid}, #{pid})"), ", ")
    if length(deletes) > 0 do
      Repo.query("DELETE FROM recommended_posts WHERE (user_id, post_id) IN (#{dels})")
    end
    timestamp =
      DateTime.utc_now()
      |> DateTime.truncate(:second)
    placeholders = %{timestamp: timestamp}
    Enum.map(inserts, fn r ->
      %{user_id: r.user_id, post_id: r.post_id, rating: r.rating,
      inserted_at: {:placeholder,  :timestamp}, updated_at: {:placeholder,  :timestamp}}
    end)
    |>
    Enum.chunk_every(2000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(RecommendedPost, chunk, placeholders: placeholders,  on_conflict: :replace_all, conflict_target: [:user_id, :post_id])
    end)
  end


end
