defmodule LockedIn.Recommender do
  use Rustler, otp_app: :locked_in, crate: "recommender"
  def main(_user, _jobs) do
    error()
  end

  def construct_matrix(_users, _jobs, _ratings) do
    error()
  end
  defp error(), do: :erlang.nif_error(:nif_not_loaded)

end
