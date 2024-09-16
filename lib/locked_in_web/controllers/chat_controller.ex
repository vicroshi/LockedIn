 LockedInWeb.ChatController do
  use LockedInWeb, :controller

  alias LockedIn.Chats
  alias LockedIn.Chats.{Chat, Message}

  action_fallback LockedInWeb.FallbackController

  plug :not_same when action in [:create, :update, :delete]

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

  # defp not_same(conn, _) do
  #   if is_nil(conn.params["user2_id"]) || conn.params["user2_id"] == conn.assigns.current_user.id do
  #     conn |> resp(:bad_request, "bad request") |> send_resp() |> halt()
  #   else
  #     conn
  #   end
  # end

end
