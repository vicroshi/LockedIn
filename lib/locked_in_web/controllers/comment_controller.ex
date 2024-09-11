defmodule LockedInWeb.CommentController do
  use LockedInWeb, :controller

  alias LockedIn.Posts
  alias LockedIn.Posts.Comment

  action_fallback LockedInWeb.FallbackController
  import LockedInWeb.Plugs.PostPlugs
  import LockedIn.Helpers

  plug :fetch_post when action in [:create, :delete, :index]


  def index(conn, _params) do
    post = conn.assigns.post |> with_assoc(:comments)
    render(conn, :index, comments: post.comments |> with_assoc(:user))
  end

  def create(conn, %{"comment" => comment_params}) do
    with {:ok, %Comment{} = comment} <- Posts.create_comment(conn.assigns.post,conn.assigns.current_user.id,comment_params)  do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", ~p"/api/comments/#{comment}")
      |> render(:show, comment: comment|> with_assoc(:user))
    end
  end

  def show(conn, %{"id" => id}) do
    comment = Posts.get_comment!(id) |> with_assoc(:user)
    render(conn, :show, comment: comment)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Posts.get_comment!(id)

    with {:ok, %Comment{} = comment} <- Posts.update_comment(comment, comment_params) do
      render(conn, :show, comment: comment)
    end
  end

  def delete(conn, %{"comment_id" => id}) do
    comment = Posts.get_comment!(id)

    with {:ok, %Comment{}} <- Posts.delete_comment(comment) do
      send_resp(conn, :no_content, "")
    end
  end
end
