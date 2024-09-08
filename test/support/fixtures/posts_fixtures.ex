defmodule LockedIn.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LockedIn.Posts` context.
  """

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
      |> LockedIn.Posts.create_post()

    post
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> LockedIn.Posts.create_comment()

    comment
  end
end
