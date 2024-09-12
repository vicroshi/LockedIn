defmodule LockedInWeb.NotificationController do
  use LockedInWeb, :controller
  alias LockedIn.Accounts
  # alias LockedIn.Posts.Post
  # alias LockedIn.Posts.Like
  action_fallback LockedInWeb.FallbackController
  import LockedInWeb.Plugs.PostPlugs
  import LockedIn.Helpers
  # plug :fetch_post when action in [:index, :show, :update, :delete, :like, :unlike]

  # def action(conn, _) do
    # post_id = conn.params["post_id"]
    # post = conn.assigns.post ||
    # args = [conn, conn.params, post]
    # apply(__MODULE__, action_name(conn), args)
  # end

  def index(conn, _params) do
    user =  conn.assigns.current_user |> with_assoc([:notifications])
    render(conn, :index, notifications: user.notifications |> with_assoc([:sender]))
  end

  def update(conn, %{"notification_id" => notif_id}) do
    notification = Accounts.get_notification_by_user(conn.assigns.current_user.id,notif_id)
    if is_nil(notification) do
      conn
      # |> put_status(:unauthorized )
      |> send_resp(401,"unauthorized action")
    else
      with {:ok, _} <- Accounts.update_notification(notification) do
        render(conn, :show, notification: notification)
      end
    end
  end

end
