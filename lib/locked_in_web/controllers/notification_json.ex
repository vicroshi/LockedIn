defmodule LockedInWeb.NotificationJSON do
  alias LockedIn.Accounts.Notification

  def index(%{notifications: notifications}) do
    %{data: for(notification <- notifications, do: data_with_user(notification))}
  end

  def show(%{notification: notification}) do
    %{data: data(notification)}
  end

  defp data(%LockedIn.Accounts.Notification{} = notification) do
    %{
      id: notification.id,
      sender_id: notification.sender_id,
      recipient_id: notification.recipient_id,
      post_id: notification.post_id,
      comment_id: notification.comment_id,
      created_at: notification.inserted_at,
      is_read: notification.is_read
    }
  end

  defp data_with_user(%LockedIn.Accounts.Notification{} = notification) do
    %{
      id: notification.id,
      sender_id: notification.sender_id,
      sender_fname: notification.sender.firstname,
      sender_lname: notification.sender.lastname,
      recipient_id: notification.recipient_id,
      post_id: notification.post_id,
      comment_id: notification.comment_id,
      created_at: notification.inserted_at,
      is_read: notification.is_read
    }
  end

end
