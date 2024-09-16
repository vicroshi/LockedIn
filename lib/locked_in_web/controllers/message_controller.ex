defmodule LockedInWeb.MessageController do
  use LockedInWeb, :controller

  alias LockedIn.Chats
  alias LockedIn.Chats.Message
  import LockedIn.Helpers
  action_fallback LockedInWeb.FallbackController

  plug :fetch_chat when action in [:index, :update]

  def index(conn, %{"user2_id" => _user_id}) do
    messages = conn.assigns.chat.messages |> with_assoc([:receiver, :sender])
    IO.inspect(messages)
    render(conn, :index, messages: messages)
  end

  def create(conn, %{"message" => _message_params, "user2_id" => _user_id} = params) do
    IO.inspect(params)
    with {:ok, %Message{} = message} <- Chats.create_message(conn.assigns.current_user.id ,params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/messages/#{message}")
      |> render(:show, message: message)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Chats.get_message!(id)
    render(conn, :show, message: message)
  end

  def update(conn, %{"user2_id" => _user2_id}) do
    with {_, %Message{} = messages} <- Chats.read_messages(con.assigns.chat.id) do
      render(conn, :show, message: message)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Chats.get_message!(id)

    with {:ok, %Message{}} <- Chats.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end

  defp fetch_chat(conn, _) do
   case Integer.parse(conn.params["user2_id"]) do
      {user2_id, _} ->
        chat = Chats.get_chat_by_users(conn.assigns.current_user.id, user2_id)
        case chat do
          nil -> conn |>resp(:not_found, "bad request") |> send_resp() |> halt()
          _ -> conn |> assign(:chat, chat)
        end
      :error -> conn |> resp(:not_found, "bad request") |> send_resp() |> halt()
   end
  end
end
