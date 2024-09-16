defmodule LockedInWeb.Plugs.ChatPlugs do
  import Plug.Conn
  alias LockedIn.Chats
  alias LockedIn.Chats.Message
  alias LockedIn.Chats.Chat
  alias LockedIn.Accounts
  import LockedIn.Helpers
  def ensure_connected(conn, _) do
    if Accounts.connected?(conn.assigns.current_user, conn.params["user2_id"]) do
      conn
    else
      conn
      |> send_resp(:forbidden, "You are not connected to this user")
      |> halt()
    end
  end
end
