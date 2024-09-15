defmodule LockedInWeb.MessageController do
  use LockedInWeb, :controller

  alias LockedIn.Accounts
  alias LockedIn.Accounts.Message

  action_fallback LockedInWeb.FallbackController

  def index(conn, _params) do
    messages = Accounts.list_messages()
    render(conn, :index, messages: messages)
  end

  def create(conn, %{"message" => message_params}) do
    with {:ok, %Message{} = message} <- Accounts.create_message(message_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/messages/#{message}")
      |> render(:show, message: message)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Accounts.get_message!(id)
    render(conn, :show, message: message)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Accounts.get_message!(id)

    with {:ok, %Message{} = message} <- Accounts.update_message(message, message_params) do
      render(conn, :show, message: message)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Accounts.get_message!(id)

    with {:ok, %Message{}} <- Accounts.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end
end
