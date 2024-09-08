defmodule LockedIn.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LockedIn.Jobs` context.
  """

  @doc """
  Generate a job_offer.
  """
  def job_offer_fixture(attrs \\ %{}) do
    {:ok, job_offer} =
      attrs
      |> Enum.into(%{
        description: "some description",
        skills: ["option1", "option2"],
        title: "some title"
      })
      |> LockedIn.Jobs.create_job_offer()

    job_offer
  end

  @doc """
  Generate a job_application.
  """
  def job_application_fixture(attrs \\ %{}) do
    {:ok, job_application} =
      attrs
      |> Enum.into(%{
        cv: "some cv"
      })
      |> LockedIn.Jobs.create_job_application()

    job_application
  end
end
