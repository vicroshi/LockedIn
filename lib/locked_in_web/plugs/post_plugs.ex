defmodule LockedInWeb.Plugs.PostPlugs do
  import Plug.Conn
  alias LockedIn.Posts
  def fetch_post(conn, _) do
    post_id = conn.params["post_id"]
    # post = Posts.get_post_by_user!(post_id,conn.assigns.current_user.id)
    post = Posts.get_post!(post_id) |> Posts.with_assoc([:user])
    IO.inspect(post)
    case post do
      nil ->
        conn |> halt()
      _ ->
        conn |> assign(:post, post)
    end
  end
end
