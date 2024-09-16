defmodule LockedInWeb.MessageJSON do
  alias LockedIn.Chats.Message

  @doc """
  Renders a list of messages.
  """
  def index(%{messages: messages}) do
    %{data: for(message <- messages, do: data(message))}
  end

  @doc """
  Renders a single message.
  """
  def show(%{message: message}) do
    %{data: data(message)}
  end

  defp data(%Message{} = message) do
    %{
      id: message.id,
      content: message.content,
      sender_id: message.sender_id,
      receiver_id: message.receiver_id,
      is_read: message.is_read,
      chat_id: message.chat_id,
      sent_at: message.inserted_at
    }
  end
end
