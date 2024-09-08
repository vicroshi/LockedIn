# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LockedIn.Repo.insert!(%LockedIn.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# priv/repo/seeds.exs

alias LockedIn.Repo
alias LockedIn.Posts.Post
alias LockedIn.Accounts.User
alias LockedIn.Accounts.UserEducation
alias LockedIn.Accounts.UserExperience
alias LockedIn.Accounts.UserSkill
alias LockedIn.Skills.Skill
# Ensure the Repo is started
{:ok, _} = Application.ensure_all_started(:locked_in)

# Sample users (assuming you have some users in the database)
user1 = Repo.get!(User, 1)
user2 = Repo.get!(User, 2)

# Recursive function to insert posts
defmodule Seeder do
  def insert_posts(_, 0), do: IO.puts("10 posts have been seeded successfully!")

  def insert_posts(users, count) do
    user = Enum.at(users, rem(count, length(users)))
    post = %Post{
      content: "This is post number #{11 - count}",
      media_path: "/media/media#{11 - count}.jpg",
      posted_at: ~U[2023-01-#{count} 12:00:00Z],
      user_id: user.id
    }

    Repo.insert!(post)
    insert_posts(users, count - 1)
  end
end

# Insert 10 posts
Seeder.insert_posts([user1, user2], 10)
