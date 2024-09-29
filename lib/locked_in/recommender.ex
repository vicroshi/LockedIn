defmodule LockedIn.Recommender do
  use Rustler, otp_app: :locked_in, crate: "recommender"
  def job_recommendations(_user, _jobs, _views, _applies, _skills, _recommendations) do
    error()
  end

  def post_recommendations(_user, _posts, _views, _likes, _comments, _recommendations) do
    error()
  end

  defp error(), do: :erlang.nif_error(:nif_not_loaded)

end
