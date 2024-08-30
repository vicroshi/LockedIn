defmodule LockedInWeb.ConnectionJSON do
  alias LockedIn.Accounts.Connection

  @doc """
  Renders a list of connections.
  """
  def index(%{connections: connections}) do
    %{data: for(connection <- connections, do: data(connection))}
  end

  @doc """
  Renders a single connection.
  """
  def show(%{connection: connection}) do
    %{data: data(connection)}
  end

  defp data(%Connection{} = connection) do
    %{
      requester_id: connection.requester_id,
      requestee_id: connection.requestee_id,
      has_accepted: connection.has_accepted
    }
  end
end
