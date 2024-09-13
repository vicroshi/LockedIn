defmodule LockedInWeb.UserJSON do
  alias Ecto.Query.Builder.Lock
  alias LockedIn.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def register(%{token: token, user: user, conn: conn}) do
    %{
      token: token,
      user_data: data(user)
    }
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end



  defp data(%User{} = user) do
    %{
      id: user.id,
      firstname: user.firstname,
      lastname: user.lastname,
      # email: user.email,
      # password: user.password,
      phone: user.phone
    }
  end

  defp data(%LockedIn.Accounts.UserExperience{} = experience) do
    %{
      id: experience.id,
      title: experience.title,
      company: experience.company,
      start_date: experience.start_date,
      end_date: experience.end_date,
      description: experience.description
    }
  end

  defp data(%LockedIn.Accounts.UserEducation{} = education) do
    %{
      id: education.id,
      school: education.school,
      degree: education.degree,
      start_date: education.start_date,
      end_date: education.end_date,
      description: education.description
    }
  end


  # def test(%{user: user}) do
    # Map.from_struct(user)
  # end

  def profile(%{user: user}) do
    # IO.inspect(user.skills)
    %{
      id: user.id,
      firstname: user.firstname,
      lastname: user.lastname,
      phone: user.phone,
      education: for(education <- user.education, do: data(education)),
      experience: for(experience <- user.experience, do: data(experience)),
      skills: for(skill <- user.skills, do: %{"name" => skill.name, "public" => skill.public}),
    }
  end

  def notifications(%{notifs: notifications}) do
    %{data: for(notification <- notifications, do: data(notification))}
  end

end
