defmodule LockedInWeb.UserRegistrationController do
  use LockedInWeb, :controller

  alias LockedIn.Accounts
  alias LockedIn.Accounts.User
  alias LockedInWeb.UserAuth
  action_fallback LockedInWeb.FallbackController
  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # {:ok, _} =
        #   Accounts.deliver_user_confirmation_instructions(
        #     user,
        #     &url(~p"/users/confirm/#{&1}")
        #   )

        conn
        |> UserAuth.log_in_user(user)
        |> put_view(json: LockedInWeb.UserJSON)
        |> render(:show, user: user)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
        # json(conn, %{errors: changeset.errors})
        # render(conn, :new, changeset: changeset)
    end
  end
end
