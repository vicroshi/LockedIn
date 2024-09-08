defmodule LockedIn.Repo.Migrations.DropLikesPostidIndex do
  use Ecto.Migration

  def change do
    drop index(:likes, [:user_id])  # redundant index
    drop index(:likes, [:post_id, :user_id], name: :likes_post_id_user_id_index)  # redundant index
  end
end
