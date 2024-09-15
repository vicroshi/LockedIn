defmodule LockedInWeb.MessageController do
  use LockedInWeb, :controller

  alias LockedIn.Chats
  alias LockedIn.Chats.Message

  action_fallback LockedInWeb.FallbackController

  def index(conn, _params) do
    messages = Chats.list_messages()
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

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Chats.get_message!(id)

    with {:ok, %Message{} = message} <- Chats.update_message(message, message_params) do
      render(conn, :show, message: message)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Chats.get_message!(id)

    with {:ok, %Message{}} <- Chats.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end
end
