defmodule LockedIn.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LockedIn.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        firstname: "some firstname",
        lastname: "some lastname",
        password: "some password",
        phone: "some phone"
      })
      |> LockedIn.Users.create_user()

    user
  end
end
