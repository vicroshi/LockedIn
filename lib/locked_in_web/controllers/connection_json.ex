defmodule LockedInWeb.ConnectionJSON do
  alias LockedIn.Accounts.Connection

  @doc """
  Renders a list of connections.
  """
  def index(%{connections: connections}) do
    %{data: for(connection <- connections, do: data(connection))}
  end

  def index(%{connection_requests: reqs}) do
    %{data: for(req <- reqs, do: data_req(req))}
  end
  @doc """
  Renders a single connection.
  """
  def show(%{connection: connection}) do
    %{data: data(connection)}
  end

  defp data_req(%Connection{} = req) do
    %{
      requester_id: req.requester_id,
      requester_fname: req.requester.firstname,
      requester_lname: req.requester.lastname,
      inserted_at: req.inserted_at
    }
  end

  defp data(%Connection{} = connection) do
    %{
      requester_id: connection.requester_id,
      requestee_id: connection.requestee_id,
      has_accepted: connection.has_accepted
    }
  end
end
