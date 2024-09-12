defmodule LockedIn.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias LockedIn.Accounts.UserSkill
  alias Ecto.Changeset
  alias LockedIn.Repo

  alias LockedIn.Accounts.{User, UserToken, UserNotifier,Connection, Notification}
  alias LockedIn.Posts.{Post, Like}
  ## Database getters

  def get_feed(user) do
    user_id = user.id
    # user = get_user!(user_id)
    # posts = Ecto.assoc(user,:posts) |> Repo.all() |> IO.inspect(label: "posts")
    # liked_posts = Ecto.assoc(user,:liked_posts) |> Repo.all() |> IO.inspect(label: "liked_posts")
    # connection_posts = Ecto.assoc(user,:connection_posts) |> Repo.all() |> IO.inspect(label: "connection_posts")
    # connection_liked_posts = Ecto.assoc(user,:connection_liked_posts) |> Repo.all() |> IO.inspect(label: "connection_liked_posts")
    # reverse_connection_posts = Ecto.assoc(user,:reverse_connection_posts) |> Repo.all() |> IO.inspect(label: "reverse_connection_posts")
    # reverse_connection_liked_posts = Ecto.assoc(user,:reverse_connection_liked_posts) |> Repo.all() |> IO.inspect(label: "reverse_connection_liked_posts", syntax_colors: [string: :blue, atom: :red])    # |> Ecto.assoc(:connection_posts)
    # Repo.preload(user,[:posts, :connection_posts, :reverse_connection_posts, :connection_liked_posts, :reverse_connection_liked_posts])
    # Repo.preload(user,[:posts])
    # Repo.preload(user,[:liked_posts])
    # Repo.preload(user,[:connection_posts])
    # Repo.preload(user,[:reverse_connection_posts])
    # Repo.preload(user,[:connection_liked_posts])
    # Repo.preload(user,[:reverse_connection_liked_posts])
    # |>
    # IO.inspect(label: "user")
    # Enum.uniq(user.posts ++ user.connection_posts ++ user.reverse_connection_posts ++ user.connection_liked_posts ++ user.reverse_connection_posts ++ user.reverse_connection_liked_posts) |>
    # Enum.sort_by(& &1.posted_at, &>=/2)
    []
    user_posts_query = from p in Post, where: p.user_id == ^user_id

    user_liked_posts_query =
      from p in Post,
        join: l in Like,
        on: l.post_id == p.id,
        where: l.user_id == ^user_id
      # end
    connection_posts_query =
      from p in Post,
        join: c in Connection,
        on: c.requestee_id == p.user_id,
        where: c.requester_id == ^user_id and c.has_accepted == true

    connection_liked_posts_query =
      from p in Post,
        join: l in Like,
        on: l.post_id == p.id,
        join: c in Connection,
        on: c.requestee_id == l.user_id,
        where: c.requester_id == ^user_id  and c.has_accepted == true

    reverse_connection_posts_query =
      from p in Post,
        join: c in Connection,
        on: c.requester_id == p.user_id,
        where: c.requestee_id == ^user_id and c.has_accepted == true

    reverse_connection_liked_posts_query =
      from p in Post,
        join: l in Like,
        on: l.post_id == p.id,
        join: c in Connection,
        on: c.requester_id == l.user_id,
        where: c.requestee_id == ^user_id and c.has_accepted == true

    feed_query =
      user_posts_query
      |> union(^user_liked_posts_query)
      |> union(^connection_posts_query)
      |> union(^connection_liked_posts_query)
      |> union(^reverse_connection_posts_query)
      |> union(^reverse_connection_liked_posts_query)

    # feed_query =
      # Ecto.assoc(user, :posts)
      # |> union(^Ecto.assoc(user, :liked_posts))
      # |> union(^Ecto.assoc(user, :connection_posts))
      # |> union(^Ecto.assoc(user, :connection_liked_posts))
      # |> union(^Ecto.assoc(user, :reverse_connection_posts))
      # |> union(^Ecto.assoc(user, :reverse_connection_liked_posts))
    final_query = from p in subquery(feed_query),
      order_by: [desc: p.posted_at],
      # limit: ^limit,
      # offset: ^offset,
      preload: [:user, :likes]
    Repo.all(final_query)
    |> IO.inspect(label: "feed_query")
    # |> IO.inspect(label: "feed_query")
    # IO.inspect(Ecto.assoc(user, :connection_liked_posts) |> where([p,l,c], c.has_accepted == true))
    # Ecto.Adapters.SQL.to_sql(:all,Repo,IO.inspect(Ecto.assoc(user, :connection_liked_posts)))
    # |>IO.inspect()
    # IO.inspect(connection_liked_posts_query )
    # Ecto.Adapters.SQL.to_sql(:all,Repo,IO.inspect(connection_liked_posts_query))
    # |>IO.inspect()
    # []
  end
  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_with_liked_posts(id), do: Repo.one(from u in User, where: u.id == ^id, preload: [:liked_posts])

  # def get_users_liked_posts(user), do: Repo.preload(user, :liked_posts)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    changeset = User.registration_changeset(%User{},attrs)

    Repo.insert(changeset)
  end

  @doc """
  Gets session token for user
  """
  def get_session_token(user) do
    {:ok, query} = UserToken.by_user_and_contexts_query(user, "session")
    Repo.one(query)
  end

  @doc """
  Deletes all session tokens for user
  """
  def user_delete_all_session_token(user) do
    Repo.delete_all(UserToken.by_user_and_contexts_query(user, ["session"]))
  end

  @doc """
  Deletes all session tokens
  """
  def delete_all_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## API token auth

  @doc """
  Creates a new api token for a user.

  The token returned must be saved somewhere safe.
  This token cannot be recovered from the database.
  """
  def create_user_api_token(user) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "api-token")
    Repo.insert!(user_token)
    encoded_token
  end

  @doc """
  Fetches the user by API token.
  """
  def fetch_user_by_api_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "api-token"),
         %User{} = user <- Repo.one(query) do
      {:ok, user}
    else
      _ -> :error
    end
  end


  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  alias LockedIn.Accounts.Connection

  @doc """
  Returns the list of connections.

  ## Examples

      iex> list_connections()
      [%Connection{}, ...]

  """
  def list_connections do
    Repo.all(Connection)
  end

  @doc """
  Gets a single connection.

  Raises `Ecto.NoResultsError` if the Connection does not exist.

  ## Examples

      iex> get_connection!(123)
      %Connection{}

      iex> get_connection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_connection(%{"requester_id" => requester_id, "requestee_id" => requestee_id}) do
      Repo.get_by(Connection, requester_id: requester_id, requestee_id: requestee_id)
  end

  def get_connection_requests(user_id) do
    Repo.all from c in Connection, where: c.requestee_id == ^user_id and c.has_accepted == false, preload: [:requester], order_by: [desc: c.inserted_at]
  end

  def get_connections(user) do
    connections_query = user |> Ecto.assoc(:connections)
    reverse_connections_query = user |> Ecto.assoc(:reverse_connections)
    connections_query |> union(^reverse_connections_query) |> Repo.all()
    |>
    IO.inspect()
  end

  @doc """
  Creates a connection.

  ## Examples

      iex> create_connection(%{field: value})
      {:ok, %Connection{}}

      iex> create_connection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def request_connection(attrs \\ %{}) do
    %Connection{}
    |> Connection.request_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a connection.

  ## Examples

      iex> update_connection(connection, %{field: new_value})
      {:ok, %Connection{}}

      iex> update_connection(connection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def accept_connection(%Connection{} = connection) do
    connection
    |> Connection.accept_changeset()
    |> Repo.update()
  end

  def delete_connection(user, id) do
    query = from(c in Connection, where: (c.requester_id == ^id and c.requestee_id == ^user.id) or (c.requestee_id == ^id and c.requester_id == ^user.id))
    Repo.delete_all(query)
    # Repo.delete
    # user
    # |>
    # Repo.preload([:connections, :reverse_connections])
    # |>
    # IO.inspect()
  end

  @doc """
  Deletes a connection.

  ## Examples

      iex> delete_connection(connection)
      {:ok, %Connection{}}

      iex> delete_connection(connection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_connection(%Connection{} = connection) do
    Repo.delete(connection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking connection changes.

  ## Examples

      iex> change_connection(connection)
      %Ecto.Changeset{data: %Connection{}}

  """
  def change_connection(%Connection{} = connection, attrs \\ %{}) do
    Connection.changeset(connection, attrs)
  end

  def get_profile(user_id) do
    user = get_user!(user_id) |> Repo.preload([:skills])
    IO.inspect(user)
    # skills = user |> Ecto.assoc(:skills) |> Repo.all()
    # connection = get_connection()
  end

  def update_profile(user, attrs) do
    # update association skills
    case user
    |> Repo.preload([:skills])
    |> Changeset.cast(attrs, [])
    |> Changeset.cast_assoc(:skills)
    |> Changeset.cast_embed(:experience)
    |> Repo.update()
    do
     {:ok, user} ->
        # update join table association user_skills
        user_skills = Enum.reduce(user.skills,[], fn skill,acc ->
          [%{user_id: user.id, skill_id: skill.id, public: skill.public} | acc]
        end)
        IO.inspect(user_skills)
        Changeset.change(user|>Repo.preload([:user_skills]))
        |> Changeset.put_assoc(:user_skills, user_skills)
        |> Repo.update()
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_notification_by_user(user_id, notif_id) do
    Repo.get_by(Notification, recipient_id: user_id, id: notif_id)
  end

  def update_notification(notification) do
    notification
    |> Notification.read()
    |> Repo.update()
  end

end
