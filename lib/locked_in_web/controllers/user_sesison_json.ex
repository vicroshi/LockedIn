defmodule LockedInWeb.UserSesisonJson do
  def show(conn,%{token: token ,user: user}) do
    inspect(conn)
    %{
      data: %{
        token: token,
        user_data: %{
          id: user.id,
          email: user.email,
          firstname: user.firstname,
          lastname: user.lastname,
          phone: user.phone
        }
      }
    }
  end
end
