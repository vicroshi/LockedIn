defmodule LockedIn.Skills do
  @moduledoc """
  The Skills context.
  """

  import Ecto.Query, warn: false
  alias LockedIn.Repo

  alias LockedIn.Skills.Skill

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%Skill{}, ...]

  """
  def list_skills do
    Repo.all(Skill)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill!(123)
      %Skill{}

      iex> get_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill!(id), do: Repo.get!(Skill, id)

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(attrs \\ %{}) do
    %Skill{}
    |> Skill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill.

  ## Examples

      iex> delete_skill(skill)
      {:ok, %Skill{}}

      iex> delete_skill(skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill(%Skill{} = skill) do
    Repo.delete(skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{data: %Skill{}}

  """
  def change_skill(%Skill{} = skill, attrs \\ %{}) do
    Skill.changeset(skill, attrs)
  end
  def inser_and_get_all_skills([]) do
    []
  end
  def insert_and_get_all_skills(skills) do
    maps = Enum.map(skills, &%{
      name: &1["name"],
    })
    Repo.insert_all(Skill, maps, on_conflict: :nothing)
    Repo.all(
      from s in Skill,
      where: s.name in ^Enum.map(skills, & &1["name"])
      # select_merge: %{public: ^Enum.find_value(skills, fn skill -> if skill["name"] == ^s.name end)["public"]}
      )
  end

  def set_public_user_skills(skills) do
    Enum.map(skills,fn s ->
      public = Enum.find(skills, fn skill ->
        skill["name"] == s.name
      end)["public"]
      # IO.inspect(public)
      # Map.put(s, :public, public)
      Skill.set_public(s, public)
    end)
  end
end
