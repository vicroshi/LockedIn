defmodule LockedIn.Recommender do
  use Rustler, otp_app: :locked_in, crate: "recommender"
  def job_recommendations(_user, _jobs, _views, _applies, _skills) do
    error()
  end

  # def job_recommendations(_users, _jobs, _ratings) do
    # error()
  # end
  defp error(), do: :erlang.nif_error(:nif_not_loaded)

end
