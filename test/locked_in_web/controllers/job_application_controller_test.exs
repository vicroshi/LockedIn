defmodule LockedInWeb.ApplicationControllerTest do
  use LockedInWeb.ConnCase

  import LockedIn.JobsFixtures

  alias LockedIn.Jobs.Application

  @create_attrs %{
    cv: "some cv"
  }
  @update_attrs %{
    cv: "some updated cv"
  }
  @invalid_attrs %{cv: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all applications", %{conn: conn} do
      conn = get(conn, ~p"/api/applications")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create job_application" do
    test "renders job_application when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/applications", job_application: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/applications/#{id}")

      assert %{
               "id" => ^id,
               "cv" => "some cv"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/applications", job_application: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update job_application" do
    setup [:create_job_application]

    test "renders job_application when data is valid", %{conn: conn, job_application: %Application{id: id} = job_application} do
      conn = put(conn, ~p"/api/applications/#{job_application}", job_application: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/applications/#{id}")

      assert %{
               "id" => ^id,
               "cv" => "some updated cv"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, job_application: job_application} do
      conn = put(conn, ~p"/api/applications/#{job_application}", job_application: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete job_application" do
    setup [:create_job_application]

    test "deletes chosen job_application", %{conn: conn, job_application: job_application} do
      conn = delete(conn, ~p"/api/applications/#{job_application}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/applications/#{job_application}")
      end
    end
  end

  defp create_job_application(_) do
    job_application = job_application_fixture()
    %{job_application: job_application}
  end
end
