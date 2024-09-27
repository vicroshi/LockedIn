defmodule LockedInWeb.ExportController do
  use LockedInWeb, :controller
  alias LockedIn.Accounts.User
  alias LockedIn.Accounts
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
end
