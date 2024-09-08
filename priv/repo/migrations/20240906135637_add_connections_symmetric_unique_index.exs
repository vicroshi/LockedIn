defmodule LockedIn.Repo.Migrations.AddConnectionsSymmetricUniqueIndex do
  use Ecto.Migration

  def change do
    # create unique_index(:connections, [:requestee_id, :requester_id])
    drop index(:connections, :requestee_id)
    # create unique_index(:connections, ["(LEAST(requester_id,requestee_id))", "(GREATEST(requester_id,requestee_id))"], name: :connections_symmetric_index)
    # create constraint("connections", :connections_symmetric_constraint, exclude: ~s|gist (int8range(LEAST(requestee_id,requester_id),GREATEST(requestee_id,requester_id),'[]') WITH &&)|)
    # create constraint("connections", :connections_symmetric_constraint, exclude: ~s|gist ( ARRAY[`requester_id`,`requestee_id`] WITH &&)|)
    # create constraint("connections", :connections_symmetric_constraint, exclude: ~s/gist  ( LEAST(requester_id, requestee_id) WITH =, GREATEST(requester_id, requestee_id) WITH = )/)
    create unique_index("connections", ["LEAST(requester_id, requestee_id)","GREATEST(requester_id, requestee_id)"] ,name: :connections_symmetric_constraint)
  end
end
