defmodule LockedIn.Recommendations do

  import Ecto.Query, warn: false
  alias LockedIn.Repo
  alias LockedIn.Recommendations.RecJob

  def insert_ratings_jobs(ratings) do
    # timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    # entries = Enum.map(ratings, fn rating ->
      # %{
        # user_id: rating.user_id,
        # job_id: rating.job_id,
        # rating: rating.rating,
        # inserted_at: timestamp,
        # updated_at: timestamp
      # }
    # end)

  # Repo.insert_all(JobRating, entries, on_conflict: :replace_all, conflict_target: [:user_id, :job_id])
    timestamp =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    placeholders = %{timestamp: timestamp}
    Enum.map(ratings, fn r ->
      %{user_id: r.user_id, job_id: r.job_id, rating: r.rating,
      inserted_at: {:placeholder,  :timestamp}, updated_at: {:placeholder,  :timestamp}}
    end)
    |>
    Enum.chunk_every(20000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(JobRating, chunk, placeholders: placeholders,  on_conflict: :replace_all, conflict_target: [:user_id, :job_id])
    end)
  end

    # Repo.insert_all(JobRating,
      # , on_conflict: :replace_all, conflict_target: [:user_id, :job_id])


end
