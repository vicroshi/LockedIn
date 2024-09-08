defmodule LockedIn.SkillsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LockedIn.Skills` context.
  """

  @doc """
  Generate a skill.
  """
  def skill_fixture(attrs \\ %{}) do
    {:ok, skill} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> LockedIn.Skills.create_skill()

    skill
  end
end
