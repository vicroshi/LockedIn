defmodule LockedInWeb.UserController do
  use LockedInWeb, :controller

  alias LockedIn.Users
  alias LockedIn.Users.User
  alias LockedIn.Accounts
  action_fallback LockedInWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  # def register(conn, %{email: email, }params) do
    # Users.create_user()
    # token = Accounts.create_user_api_token()
    # render(conn, :register)
  # end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      token = Accounts.create_user_api_token(user)
      conn
      |> put_session(:user_token, token)
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:register, %{token: token, user: user})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
