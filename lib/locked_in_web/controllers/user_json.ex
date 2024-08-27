defmodule LockedInWeb.UserJSON do
  alias LockedIn.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def register(%{token: token, user: user, conn: conn}) do
    IO.inspect(conn.assigns.user.id)
    IO.inspect(conn.assigns.token)
    %{
      token: token,
      user_data: data(user)
    }
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end



  defp data(%User{} = user) do
    %{
      id: user.id,
      firstname: user.firstname,
      lastname: user.lastname,
      # email: user.email,
      # password: user.password,
      phone: user.phone
    }
  end
end
