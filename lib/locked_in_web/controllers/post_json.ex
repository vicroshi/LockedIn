defmodule LockedInWeb.PostJSON do
  alias LockedIn.Posts.Post

  @doc """
  Renders a list of posts.
  """
  def index(%{posts: posts}) do
    %{data: for(post <- posts, do: data(post))}
  end

  @doc """
  Renders a single post.
  """
  def show(%{post: post}) do
    %{data: data(post)}
  end

  defp data(%Post{} = post) do
    %{
      id: post.id,
      content: post.content,
      user_id: post.user_id,
      user_fname: post.user.firstname,
      user_lname: post.user.lastname,
      posted_at: post.posted_at,
      media: post.media_paths,
      like_count: post.like_count,
      comment_count: post.comment_count
    }
  end
end
