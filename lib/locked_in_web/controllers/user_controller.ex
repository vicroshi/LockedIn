defmodule LockedInWeb.UserController do
  use LockedInWeb, :controller

  alias LockedIn.Accounts
  alias LockedIn.Accounts.User
  import LockedIn.Helpers
  action_fallback LockedInWeb.FallbackController
  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  # def register(conn, %{email: email, }params) do
    # Accounts.create_user()
    # token = Accounts.create_user_api_token()
    # render(conn, :register)
  # end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      token = Accounts.create_user_api_token(user)
      conn
      |> put_session(:user_token, token)
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:register, %{token: token, user: user})
    end
  end

  # def like(conn, ) do
    #
  # end

  # def notification_index(conn, _params) do
    # user = conn.assigns.current_user |> with_assoc([:notifications])
    # render(conn, :notifications, notifs: user.notifications |> with_assoc([:sender]))
  # end

  def show(conn, %{"user_id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def show(conn, _) do
    render(conn, :show, user: conn.assigns.current_user)
  end

  def update(conn, %{"skills" => skills, "experience" => experience, "education" => education, "pfp" => _pfp} = profile_params) do
    profile_params = profile_params
    |>
    Map.put("skills", Jason.decode!(skills))
    |> Map.put("experience", Jason.decode!(experience))
    |> Map.put("education", Jason.decode!(education))

    case Accounts.update_profile(conn.assigns.current_user, profile_params) do
      {:ok, user} ->
        render(conn, :profile, user: user)
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def liked_posts(conn, %{"user_id" => user_id}) do
    # liked_posts = Accounts.get_user_with_liked_posts(user_id)
    user = Accounts.get_user!(user_id) |> with_assoc([:liked_posts])
    liked_posts = user.liked_posts
    conn
    |> put_view(LockedInWeb.PostJSON)
    |> render(:index, posts: liked_posts)
  end

  def feed(conn, _params) do
    user = conn.assigns.current_user
    feed = Accounts.get_feed(user)
    conn
    |> put_view(LockedInWeb.PostJSON)
    |> render(:index, posts: feed)
  end

  def profile(conn, %{"user_id" => user_id}) do
    user = Accounts.get_profile(user_id)
    render(conn, :profile, user: user)
  end

  def test(conn, _params) do

    feed = Accounts.test_feed(conn.assigns.current_user)
    conn
    |> put_view(LockedInWeb.PostJSON)
    |> render(:index, posts: feed)
  end

end
