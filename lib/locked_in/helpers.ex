defmodule LockedIn.Helpers do
  import Ecto.Query, warn: false
  alias LockedIn.Repo
  
  def with_assoc(struct, assocs) do
    Repo.preload(struct, assocs)
  end

end
