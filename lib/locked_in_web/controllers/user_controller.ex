defmodule LockedInWeb.UserController do
  use LockedInWeb, :controller

  alias LockedIn.Accounts
  alias LockedIn.Accounts.User
  import LockedIn.Helpers
  action_fallback LockedInWeb.FallbackController
  import Saxy.XML


  def export(conn, params) do
    ids = params["userIds"]
    # options = Enum.reduce(params["export_options"],[], fn opt,acc ->
    #   if opt === "network" do
    #     [ :connections, :reverse_connections | acc]
    #   else if opt === "experience"
    #   else
    #     [String.to_atom(opt) | acc]
    #   end
    # end)
    users = Accounts.fetch_users_data(ids)
    file = case params["export_format"] do
       "xml" -> generate_xml(users)
       "json" -> generate_json(users)
    end
    file_send(conn,file,params["export_format"])
  end

  defp generate_json(users) do
    %{
      "users" => Enum.map(users, fn user ->
        %{
          "id" => user.id,
          "name" => user.firstname <> " " <> user.lastname,
          "email" => user.email,
          "phone" => user.phone,
          "pfp" => user.pfp,
          "cv" => %{
            "education" => user.education,
            "experience" => user.experience,
            "skills" => Enum.map(user.skills, fn skill ->
              %{
                "id" => skill.id,
                "name" => skill.name
              }
            end
            )
          },
          "posts" => Enum.map(user.posts, fn post ->
            %{
              "id" => post.id,
              "content" => post.content,
              "media_paths" => post.media_paths,
            }
          end
          ),
          "comments" => Enum.map(user.comments, fn comment ->
            %{
              "id" => comment.id,
              "content" => comment.content,
              "post_id" => comment.post_id
            }
          end
          ),
          "likes" => Enum.map(user.likes, fn like ->
            %{
              "post_id" => like.post_id
            }
          end
          ),
          "jobs" => Enum.map(user.jobs, fn job ->
            %{
              "id" => job.id,
              "position" => job.position,
              "company_name" => job.company_name,
              "description" => job.description,
              "location" => job.location,
              "skills" => Enum.map(job.skills, fn skill ->
                %{
                  "id" => skill.id,
                  "name" => skill.name
                }
              end
              ),
            }
          end
          ),
          "network" => Enum.map(user.connections_join ++ user.reverse_connections_join, fn connection ->
            %{
              "user_id" => if connection.requester_id === user.id do connection.requestee_id else connection.requester_id end,
            }
          end
          )
        }
      end)
    }
    |> Jason.encode!(pretty: true)
    |> IO.inspect()
  end

  defp generate_xml(users,options \\ []) do
    IO.inspect(hd(users))
    root = element("Users",[count: length(users)],users)
    XmlBuilder.generate(root)
    # Saxy.encode!(root,[])
    # |> Floki.parse_document!()
    # |> Floki.raw_html(pretty: true)
    # users_xml = Enum.map(users, fn user ->
    #   user_elements = Enum.map(options, fn option ->
    #     element(option,[], Map.get(user, option))
    #   end)

    #   element("user", [], user_elements)
    # end)

    # document = {"users", [], users_xml}
    # Saxy.Builder.build(document)
    # |>
    # Saxy.encode!()
  end

  defp file_send(conn, content, format) do
    {content_type, filename} = case format do
      "xml" -> {"application/xml", "user_data.xml"}
      "json" -> {"application/octet-stream", "user_data.json"}
    end

    conn
    |> put_resp_content_type(content_type)
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> put_resp_header("content-transfer-encoding", "binary")
    |> put_resp_header("cache-control", "no-cache")
    |> send_resp(200, content)
  end

  def test(conn,_params) do
    json = Jason.encode!(%{
      root: %{
        child: "Content"
      }
    }, pretty: true)
    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("content-disposition", ~s(attachment; filename="test.json"))
    # |> put_resp_header("content-transfer-encoding", "binary")
    # |> put_resp_header("cache-control", "no-cache")
    |> send_resp(200, json)
  end

  def index(conn, _params) do
    users = Accounts.users(conn.assigns.current_user.id)
    render(conn, :index, users: users)
  end

  # def register(conn, %{email: email, }params) do
    # Accounts.create_user()
    # token = Accounts.create_user_api_token()
    # render(conn, :register)
  # end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      token = Accounts.create_user_api_token(user)
      conn
      |> put_session(:user_token, token)
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:register, %{token: token, user: user})
    end
  end

  # def like(conn, ) do
    #
  # end

  # def notification_index(conn, _params) do
    # user = conn.assigns.current_user |> with_assoc([:notifications])
    # render(conn, :notifications, notifs: user.notifications |> with_assoc([:sender]))
  # end

  def show(conn, %{"user_id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def show(conn, _) do
    render(conn, :show, user: conn.assigns.current_user)
  end

  def update(conn, %{"password" => password, "new_password" => new_password}) do
    user = conn.assigns.current_user
    with {:ok, %User{} = user} <- Accounts.update_user_password(user, password, new_password) do
      render(conn, :show, user: user)
    end
  end

  def update(conn, %{"email" => _new_email} = params) do
    user = conn.assigns.current_user
    with {:ok, %User{} = user} <- Accounts.update_user_email(user, params) do
      render(conn, :show, user: user)
    end
  end

  def update(conn, %{"skills" => skills, "experience" => experience, "education" => education, "pfp" => _pfp} = profile_params) do
    profile_params = profile_params
    |>
    Map.put("skills", Jason.decode!(skills))
    |> Map.put("experience", Jason.decode!(experience))
    |> Map.put("education", Jason.decode!(education))

    case Accounts.update_profile(conn.assigns.current_user, profile_params) do
      {:ok, user} ->
        render(conn, :profile, user: user)
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def liked_posts(conn, %{"user_id" => user_id}) do
    # liked_posts = Accounts.get_user_with_liked_posts(user_id)
    user = Accounts.get_user!(user_id) |> with_assoc([:liked_posts])
    liked_posts = user.liked_posts
    conn
    |> put_view(LockedInWeb.PostJSON)
    |> render(:index, posts: liked_posts)
  end

  def feed(conn, _params) do
    user = conn.assigns.current_user
    feed = Accounts.get_feed(user)
    conn
    |> put_view(LockedInWeb.PostJSON)
    |> render(:index, posts: feed)
  end

  def profile(conn, %{"user_id" => user_id}) do
    user = Accounts.get_profile(user_id)
    {status, _connection} = Accounts.get_status_with_connection(conn.assigns.current_user.id, user_id)
    render(conn, :profile, user: user |> Map.put(:status, status))
  end

  def test(conn, _params) do

    feed = Accounts.test_feed(conn.assigns.current_user)
    conn
    |> put_view(LockedInWeb.PostJSON)
    |> render(:index, posts: feed)
  end

end
