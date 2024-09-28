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
  users = Repo.all(LockedIn.Accounts.User |> limit(10))
  # users_map = users|>Enum.with_index()|>Enum.map( fn {v, k} -> {k, %LockedIn.Accounts.User{id: v.id}} end)
  Recommender.main(users,[])
  # users = Enum.with_index(Repo.all(LockedIn.Accounts.User |> limit(10)), fn user, index ->
    # {index, user}
  # end)
  # Enum.at(users, 0)
end

end
