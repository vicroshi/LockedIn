defmodule LockedIn.AllFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LockedIn.All` context.
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
      |> LockedIn.All.create_user()

    user
  end

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        media: "some media"
      })
      |> LockedIn.All.create_post()

    post
  end
end
