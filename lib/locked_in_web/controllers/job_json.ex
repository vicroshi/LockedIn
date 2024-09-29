defmodule LockedInWeb.JobJSON do
  alias LockedIn.Jobs.{Job,Application}
  alias LockedIn.Skills.Skill
  @doc """
  Renders a list of jobs.
  """
  def index(%{jobs: jobs}) do
    %{data: for(job <- jobs, do: data(job))}
  end

  @doc """
  Renders a single job.
  """
  def show(%{job: job}) do
    %{data: data(job)}
  end

  defp data(%Job{} = job) do
    IO.inspect(job)
    %{
      id: job.id,
      position: job.position,
      location: job.location,
      posted_at: job.inserted_at,
      skills: for(skill <- job.skills, do: LockedInWeb.SkillJSON.show(%{skill: skill})),
      applications: LockedInWeb.ApplicationJSON.index(%{applications: job.applications}),
      description: job.description,
      company_name: job.company_name,
      user_id: job.user_id,
      user_fname: job.user.firstname,
      user_lname: job.user.lastname,
      user_pfp: job.user.pfp,
      matching_skills: job.matching_skills,
      viewed: job.viewed,
      applied: job.applied,
      recommended: job.recommended,
    }
  end

  defp data(%Application{} = application) do
    %{
      user_id: application.applicant.id,
      # job_id: application.job_id,
      user_fname: application.applicant.firstname,
      user_lname: application.applicant.lastname,
    }
  end

  # defp data(%Skill{} = skill) do
  #   %{
  #     id: skill.id,
  #     name: skill.name,
  #   }
  # end
end
