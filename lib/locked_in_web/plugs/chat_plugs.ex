defmodule LockedInWeb.Plugs.ChatPlugs do
  import Plug.Conn
  alias LockedIn.Chats
  alias LockedIn.Chats.Message
  alias LockedIn.Chats.Chat
  alias LockedIn.Accounts
  import LockedIn.Helpers
  def ensure_connected(conn, _) do
    IO.inspect(conn.params)
    connection = Accounts.connected(conn.assigns.current_user.id, conn.params["user2_id"])
    if !is_nil(connection) do
      conn |> assign(:connection, connection)
    else
      conn
      |> send_resp(:forbidden, "You are not connected to this user")
      |> halt()
    end
  end
end
