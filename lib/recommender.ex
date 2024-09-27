defmodule Recommender do
  use Rustler, otp_app: :locked_in, crate: "recommender"
  def add(_a,_b) do
    error()
  end
  defp error(), do: :erlang.nif_error(:nif_not_loaded)

end
