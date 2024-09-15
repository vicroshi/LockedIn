defmodule LockedInWeb.ChatController do
  use LockedInWeb, :controller

  alias LockedIn.Chats
  alias LockedIn.Chats.{Chat, Message}

  action_fallback LockedInWeb.FallbackController

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

  def show(conn, %{"chat_id" => chat_id}) do
    chat = Chats.get_chat!(chat_id)
    render(conn, :show, chat: chat)
  end

  def update(conn, %{"chat_id" => chat_id, "chat" => chat_params}) do
    chat = Chats.get_chat!(chat_id)

    with {:ok, %Chat{} = chat} <- Chats.update_chat(chat, chat_params) do
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
