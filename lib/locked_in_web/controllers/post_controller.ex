defmodule LockedInWeb.PostController do
  use LockedInWeb, :controller

  alias LockedIn.Posts
  alias LockedIn.Posts.Post
  alias LockedIn.Posts.Like
  action_fallback LockedInWeb.FallbackController
  import LockedInWeb.Plugs.PostPlugs
  plug :fetch_post when action in [:show, :update, :delete, :like, :unlike]

  def action(conn, _) do
    post_id = conn.params["post_id"]
    post = if post_id, do: Posts.get_post!(post_id), else: nil
    args = [conn, conn.params, post]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params) do
    posts = Posts.list_posts_by_user(conn.assigns.current_user.id)
    render(conn, :index, posts: posts)
  end

  def create(conn, params, _post) do
    # with {:ok, %Post{} = post} <- Posts.create_post(post_params) do
    with {:ok, %Post{} = post} <- Posts.create_post(Map.put(params,"user_id",conn.assigns.current_user.id)) do
      # IO.inspect(conn)
      conn
      |> put_status(:created)
      |> render(:show, post: post)
    end
  end

  def show(conn, %{"post_id" => _id}, post) do
    # post = Posts.get_post!(id)
    render(conn, :show, post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}, post) do
    # post = Posts.get_post!(id)

    with {:ok, %Post{} = post} <- Posts.update_post(post, post_params) do
      render(conn, :show, post: post)
    end
  end

  def delete(conn, %{"id" => id}, post) do
    # post = Posts.get_post!(id)

    with {:ok, %Post{}} <- Posts.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end

  def like(conn, _params, post) do
    with {:ok,%Like{}} <- Posts.like_post(post, conn.assigns.current_user.id) do
      render(conn, :show, post: post)
    end
  end

  def unlike(conn, _params, post) do
    with {1, nil}  <-  Posts.unlike_post(post.id,conn.assigns.current_user.id) do
      render(conn, :show, post: post)
    else
      {0,nil} -> json(conn, %{errors: "already_unliked"})
    end
  end



end
