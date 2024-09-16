 defmodule LockedInWeb.ChatController do
  use LockedInWeb, :controller

  alias LockedIn.Accounts
  alias LockedIn.Chats
  alias LockedIn.Chats.{Chat, Message}
  import LockedInWeb.Plugs.ChatPlugs
  action_fallback LockedInWeb.FallbackController

  plug :ensure_connected


  def index(conn, _params) do
    chats = Chats.list_chats(conn.assigns.current_user)
    render(conn, :index, chats: chats)
  end

  def create(conn, %{"chat" => chat_params}) do
    with {:ok, %Chat{} = chat} <- Chats.create_chat(conn.assigns.current_user.id, chat_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/chats/#{chat}")
      |> render(:show, chat: chat, user: conn.assigns.current_user)
    end
  end

  def show(conn, %{"user2_id" => user_id}) do
    chat = Chats.get_chat_by_users(conn.assigns.current_user.id, user_id)
    render(conn, :show, chat: chat)
  end

  def update(conn, %{"user2_id" => user2_id}) do
    chat = Chats.read_chat(conn.assigns.current_user.id, user2_id)

    with {:ok, %Chat{} = chat} <- Chats.update_messages(chat.id) do
      render(conn, :show, chat: chat)
    end
  end

  def delete(conn, %{"chat_id" => chat_id}) do
    chat = Chats.get_chat!(chat_id)

    with {:ok, %Chat{}} <- Chats.delete_chat(chat) do
      send_resp(conn, :no_content, "")
    end
  end
end
