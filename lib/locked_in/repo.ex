defmodule LockedIn.Repo do
  use Ecto.Repo,
    otp_app: :locked_in,
    adapter: Ecto.Adapters.Postgres
end
