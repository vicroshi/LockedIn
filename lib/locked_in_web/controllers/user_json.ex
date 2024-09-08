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

  # def test(%{user: user}) do
    # Map.from_struct(user)
  # end

  def profile(%User{} = user) do
    %{
      id: user.id,
      firstname: user.firstname,
      lastname: user.lastname,
      phone: user.phone,
      education: user.education,
      experience: user.experience
    }
  end
end
