defmodule LockedIn.Chats do
  alias LockedIn.Chats.{Message,Chat}
  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias LockedIn.Repo
  alias Ecto.Multi


  def list_chats(user) do
    # user
    # |> Repo.preload(:chats)
    # |> Map.get(:chats)
    # |> IO.inspect()
    Repo.all(
      from c in Chat,
      preload: [:latest_message, :user1, :user2],
      where: c.user1_id == ^user.id or c.user2_id == ^user.id
    )
    |> IO.inspect()
  end

  def get_chat_by_users(user1_id,user2_id)  do
    Repo.one(
      from c in Chat,
      preload: [:messages],
      where: fragment("LEAST(?, ?) = LEAST(\"user1_id\", \"user2_id\")", type(^user1_id, :integer), type(^user2_id, :integer)),
      where: fragment("GREATEST(?, ?) = GREATEST(\"user1_id\", \"user2_id\")", type(^user1_id, :integer), type(^user2_id, :integer))
    )
  end

  # def read_chat(user1_id, user2_id) do
    # chat = get_chat_by_users(user1_id, user2_id)
  # end

  def create_chat(user1, attrs) do
    %Chat{user1_id: user1.id}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  def get_chat!(id), do: Repo.get!(Chat, id)

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  # def list_messages(chat_id) do
  # end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(user1_id, attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:chat, Chat.changeset(%Chat{},
        Map.put(attrs, "user1_id", user1_id) |> IO.inspect()),
        conflict_target: {:unsafe_fragment, "(LEAST(\"user1_id\", \"user2_id\"), GREATEST(\"user1_id\", \"user2_id\"))"},
         on_conflict: {:replace, [:user1_id, :user2_id]},
         returning: true)
    |> Multi.insert(:message, fn %{chat: chat} ->
      IO.inspect(chat)
      Ecto.build_assoc(chat, :messages)
      |> IO.inspect()
      |> Message.changeset(attrs["message"]
                           |> Map.put("sender_id", user1_id)
                           |> Map.put("receiver_id", attrs["user2_id"]))
    end)
    |> Repo.transaction()
    |> case  do
      {:error, _, changeset, _} ->
        {:error, changeset}
      {:ok, %{message: message}} ->
        {:ok, message} |> IO.inspect()
    end
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  def unread_query(chat_id) do
      from m in Message,
      where: m.chat_id == ^chat_id and m.is_read == false
  end

  def read_messages(chat_id) do
    Repo.update_all(unread_query(chat_id), set: [is_read: true])
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
