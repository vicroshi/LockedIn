defmodule LockedIn.Repo.Migrations.PostView do
  use Ecto.Migration

  def change do
    create table("post_views", primary_key: false) do
      add :post_id, references("posts", on_delete: :delete_all), primary_key: true
      add :user_id, references("users", on_delete: :delete_all), primary_key: true
    end
    create index("post_views", [:user_id])
    create table("job_views", primary_key: false) do
      add :job_id, references("jobs", on_delete: :delete_all), primary_key: true
      add :user_id, references("users", on_delete: :delete_all), primary_key: true
    end
    create index("job_views", [:user_id])
  end
end
