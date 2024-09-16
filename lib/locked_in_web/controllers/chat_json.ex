defmodule LockedInWeb.ChatJSON do
  alias LockedIn.Chats.Chat

  @doc """
  Renders a list of chats.
  """
  def index(%{chats: chats, current_user: user}) do
    %{data: for(chat <- chats, do: data(chat, user))}
  end

  @doc """
  Renders a single chat.
  """
  def show(%{chat: chat}) do
    %{data: data(chat)}
  end

  def show(%{chat: chat, user: user}) do
    %{data: data(chat, user)}
  end

  defp data(chat, user) do
    other_user = if user.id == chat.user1_id do chat.user2 else chat.user1 end
    %{
      id: chat.id,
      user_id: other_user.id,
      user_fname: other_user.firstname,
      user_lname: other_user.lastname,
      latest_message: if !is_nil(chat.latest_message) do LockedInWeb.MessageJSON.show(%{message: chat.latest_message}) else nil end
    }
  end

  defp data(%Chat{} = chat) do
    %{
      id: chat.id,
      user1_id: chat.user1_id,
      user2_id: chat.user2_id,

      # latest_messag: LockedInWeb.MessageJSON.show(%{message: chat.latest_message})
    }
  end
end
