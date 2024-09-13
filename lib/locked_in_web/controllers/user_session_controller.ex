defmodule LockedInWeb.UserSessionController do
  use LockedInWeb, :controller

  # alias Ecto.Query.Builder.Lock
  alias LockedIn.Accounts
  alias LockedInWeb.UserAuth
  action_fallback LockedInWeb.FallbackController
  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  # def create(conn, %{"user" => user_params}) do
  #   %{"email" => email, "password" => password} = user_params

  #   if user = Accounts.get_user_by_email_and_password(email, password) do
  #     conn
  #     |> UserAuth.log_in_user(user, user_params)
  #     # token = conn.get_session("user_token")
  #     |>
  #     render(conn,:show,%{token: Accounts.g, user: user})
  #   else
  #     # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
  #     render(conn, :new, error_message: "Invalid email or password")
  #   end
  # end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> UserAuth.log_in_user(user, user_params)
      |> put_view(json: LockedInWeb.UserJSON)
      |> render("show.json", user: user)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_status(:not_found)
      |> json(%{errors: "Invalid email or password"})
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
    |> json(%{message: "Logged out successfully"})

  end
end
