defmodule LockedIn.JobsTest do
  use LockedIn.DataCase

  alias LockedIn.Jobs

  describe "job_offers" do
    alias LockedIn.Jobs.JobOffer

    import LockedIn.JobsFixtures

    @invalid_attrs %{description: nil, title: nil, skills: nil}

    test "list_job_offers/0 returns all job_offers" do
      job_offer = job_offer_fixture()
      assert Jobs.list_job_offers() == [job_offer]
    end

    test "get_job_offer!/1 returns the job_offer with given id" do
      job_offer = job_offer_fixture()
      assert Jobs.get_job_offer!(job_offer.id) == job_offer
    end

    test "create_job_offer/1 with valid data creates a job_offer" do
      valid_attrs = %{description: "some description", title: "some title", skills: ["option1", "option2"]}

      assert {:ok, %JobOffer{} = job_offer} = Jobs.create_job_offer(valid_attrs)
      assert job_offer.description == "some description"
      assert job_offer.title == "some title"
      assert job_offer.skills == ["option1", "option2"]
    end

    test "create_job_offer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job_offer(@invalid_attrs)
    end

    test "update_job_offer/2 with valid data updates the job_offer" do
      job_offer = job_offer_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", skills: ["option1"]}

      assert {:ok, %JobOffer{} = job_offer} = Jobs.update_job_offer(job_offer, update_attrs)
      assert job_offer.description == "some updated description"
      assert job_offer.title == "some updated title"
      assert job_offer.skills == ["option1"]
    end

    test "update_job_offer/2 with invalid data returns error changeset" do
      job_offer = job_offer_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job_offer(job_offer, @invalid_attrs)
      assert job_offer == Jobs.get_job_offer!(job_offer.id)
    end

    test "delete_job_offer/1 deletes the job_offer" do
      job_offer = job_offer_fixture()
      assert {:ok, %JobOffer{}} = Jobs.delete_job_offer(job_offer)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_offer!(job_offer.id) end
    end

    test "change_job_offer/1 returns a job_offer changeset" do
      job_offer = job_offer_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job_offer(job_offer)
    end
  end

  describe "job_applications" do
    alias LockedIn.Jobs.JobApplication

    import LockedIn.JobsFixtures

    @invalid_attrs %{cv: nil}

    test "list_job_applications/0 returns all job_applications" do
      job_application = job_application_fixture()
      assert Jobs.list_job_applications() == [job_application]
    end

    test "get_job_application!/1 returns the job_application with given id" do
      job_application = job_application_fixture()
      assert Jobs.get_job_application!(job_application.id) == job_application
    end

    test "create_job_application/1 with valid data creates a job_application" do
      valid_attrs = %{cv: "some cv"}

      assert {:ok, %JobApplication{} = job_application} = Jobs.create_job_application(valid_attrs)
      assert job_application.cv == "some cv"
    end

    test "create_job_application/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job_application(@invalid_attrs)
    end

    test "update_job_application/2 with valid data updates the job_application" do
      job_application = job_application_fixture()
      update_attrs = %{cv: "some updated cv"}

      assert {:ok, %JobApplication{} = job_application} = Jobs.update_job_application(job_application, update_attrs)
      assert job_application.cv == "some updated cv"
    end

    test "update_job_application/2 with invalid data returns error changeset" do
      job_application = job_application_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job_application(job_application, @invalid_attrs)
      assert job_application == Jobs.get_job_application!(job_application.id)
    end

    test "delete_job_application/1 deletes the job_application" do
      job_application = job_application_fixture()
      assert {:ok, %JobApplication{}} = Jobs.delete_job_application(job_application)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_application!(job_application.id) end
    end

    test "change_job_application/1 returns a job_application changeset" do
      job_application = job_application_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job_application(job_application)
    end
  end
end
