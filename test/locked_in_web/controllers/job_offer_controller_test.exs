defmodule LockedInWeb.JobOfferControllerTest do
  use LockedInWeb.ConnCase

  import LockedIn.JobsFixtures

  alias LockedIn.Jobs.JobOffer

  @create_attrs %{
    description: "some description",
    title: "some title",
    skills: ["option1", "option2"]
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    skills: ["option1"]
  }
  @invalid_attrs %{description: nil, title: nil, skills: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all job_offers", %{conn: conn} do
      conn = get(conn, ~p"/api/job_offers")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create job_offer" do
    test "renders job_offer when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/job_offers", job_offer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/job_offers/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "skills" => ["option1", "option2"],
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/job_offers", job_offer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update job_offer" do
    setup [:create_job_offer]

    test "renders job_offer when data is valid", %{conn: conn, job_offer: %JobOffer{id: id} = job_offer} do
      conn = put(conn, ~p"/api/job_offers/#{job_offer}", job_offer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/job_offers/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "skills" => ["option1"],
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, job_offer: job_offer} do
      conn = put(conn, ~p"/api/job_offers/#{job_offer}", job_offer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete job_offer" do
    setup [:create_job_offer]

    test "deletes chosen job_offer", %{conn: conn, job_offer: job_offer} do
      conn = delete(conn, ~p"/api/job_offers/#{job_offer}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/job_offers/#{job_offer}")
      end
    end
  end

  defp create_job_offer(_) do
    job_offer = job_offer_fixture()
    %{job_offer: job_offer}
  end
end
