defmodule LockedInWeb.ConnectionControllerTest do
  use LockedInWeb.ConnCase

  import LockedIn.AccountsFixtures

  alias LockedIn.Accounts.Connection

  @create_attrs %{
    has_accepted: true
  }
  @update_attrs %{
    has_accepted: false
  }
  @invalid_attrs %{has_accepted: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all connections", %{conn: conn} do
      conn = get(conn, ~p"/api/connections")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create connection" do
    test "renders connection when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/connections", connection: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/connections/#{id}")

      assert %{
               "id" => ^id,
               "has_accepted" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/connections", connection: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update connection" do
    setup [:create_connection]

    test "renders connection when data is valid", %{conn: conn, connection: %Connection{id: id} = connection} do
      conn = put(conn, ~p"/api/connections/#{connection}", connection: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/connections/#{id}")

      assert %{
               "id" => ^id,
               "has_accepted" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, connection: connection} do
      conn = put(conn, ~p"/api/connections/#{connection}", connection: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete connection" do
    setup [:create_connection]

    test "deletes chosen connection", %{conn: conn, connection: connection} do
      conn = delete(conn, ~p"/api/connections/#{connection}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/connections/#{connection}")
      end
    end
  end

  defp create_connection(_) do
    connection = connection_fixture()
    %{connection: connection}
  end
end
