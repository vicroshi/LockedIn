defmodule LockedInWeb.ConnectionController do
  use LockedInWeb, :controller

  alias LockedIn.Accounts
  alias LockedIn.Accounts.Connection
  import LockedIn.Helpers
  action_fallback LockedInWeb.FallbackController
  plug :not_same when action in [:request, :accept, :delete]

  def index(conn, _params) do
    # connections = Accounts.list_connections()
    connections = Accounts.get_connections(conn.assigns.current_user)
    conn
    |> put_view(json: LockedInWeb.UserJSON)
    |> render(:index, users: connections)
  end

  def request_index(conn, _params) do
    reqs = Accounts.get_connection_requests(conn.assigns.current_user.id)
    render(conn, :index, connection_requests: reqs)
  end

  def request(conn, %{"requestee_id" => requestee_id}) do
    connection_params = %{"requestee_id" => requestee_id,"requester_id" => conn.assigns.current_user.id}
    with {:ok, %Connection{} = connection} <- Accounts.request_connection(connection_params) do
      conn
      |> put_status(:created)
      |> render(:show, connection: connection)
    else
      {:error, %Ecto.Changeset{}} -> {:error, :already_requested}
    end
  end

  def accept(conn, %{"requester_id" => requester_id}) do
    # connection_params = %{"requester_id" => requester_id,"requestee_id" => conn.assigns.current_user.id}
      connection = Accounts.get_request(requester_id, conn.assigns.current_user.id)
    if is_nil(connection) do
      {:error, :not_found}
    else
      with {:ok, %Connection{} = connection} <- Accounts.accept_connection(connection) do
        conn
        |> put_status(:created)
        |> render(:show, connection: connection)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    connection = Accounts.get_connection(id)
    render(conn, :show, connection: connection)
  end

  def update(conn, %{"id" => id, "connection" => connection_params}) do
    connection = Accounts.get_connection(id)

    with {:ok, %Connection{} = connection} <- Accounts.update_connection(connection, connection_params) do
      render(conn, :show, connection: connection)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    # Accounts.delete_connection(user,id)

    with {count, nil} when count <= 1 <- Accounts.delete_connection(user,id) do
      send_resp(conn, :no_content, "")
    end
  end

  defp not_same(conn,_opt) do
    user_id = conn.params["requester_id"] || conn.params["requestee_id"] || conn.params["id"]
    user = conn.assigns.current_user
    if not is_nil(user_id) && String.to_integer(user_id) != user.id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{errors: "cannot request connection to self"})
      |> halt()
    end
  end
end
