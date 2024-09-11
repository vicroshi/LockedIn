defmodule LockedInWeb.CommentJSON do
  alias LockedIn.Posts.Comment

  @doc """
  Renders a list of comments.
  """
  def index(%{comments: comments}) do
    %{data: for(comment <- comments, do: data(comment))}
  end

  @doc """
  Renders a single comment.
  """
  def show(%{comment: comment}) do
    %{data: data(comment)}
  end

  defp data(%Comment{} = comment) do
    %{
      id: comment.id,
      content: comment.content,
      user_id: comment.user_id,
      user_fname: comment.user.firstname,
      user_lname: comment.user.lastname,
    }
  end
end
