defmodule LockedIn.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Flop.CustomTypes.Like
  alias LockedIn.Repo
  alias Ecto.Multi
  alias LockedIn.Posts.Post
  alias LockedIn.Posts.Like
  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  def list_posts_by_user(user_id) do
    Repo.all(from(p in Post, where: p.user_id == ^user_id))
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)
  def get_post_by_user!(post_id,user_id) do
    Repo.get_by(Post, [id: post_id, user_id: user_id])
  end
  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    IO.inspect(attrs)
    medias = attrs["media"] || []
    media_names = Enum.reduce(medias, [], fn media, acc ->
      case media do
        %Plug.Upload{} = upload ->
          filename = Ecto.UUID.generate <> upload.filename
          File.cp!(upload.path, Path.join([LockedIn.upload_dir,filename]))
          [filename | acc]
        _ ->
          acc
      end
    end)
    attrs = Map.put(attrs, "media_paths", media_names)
    |> IO.inspect()
    case %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert() do
      {:ok, post} -> {:ok, post}
      {:error, changeset} ->
        Enum.each(media_names, fn media_name ->
          File.rm(Path.join([LockedIn.upload_dir,media_name]))
        end)
        {:error, changeset}
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def like_post(%Post{} = post, user_id) do
    Multi.new()
    |> Multi.insert(:like, post |> Ecto.build_assoc(:likes, user_id: user_id))
    |> Multi.merge(fn %{like: _like} ->
        if post.user_id != user_id do
          Multi.new()
          |> Multi.insert(:notification, post |> Ecto.build_assoc(:notification,
           %{sender_id: user_id,
            recipient_id: post.user_id,
            post_id: post.id,
            comment_id: nil}))
        else
          Multi.new()
        end
      end)
    |> Repo.transaction()
    |> case do
      {:ok, %{like: like}} ->
        {:ok, like}
      {:error, _} ->
        {:error, %Ecto.Changeset{}}
    end
  end

  def unlike_post(post_id, user_id) do
    query = from(l in Like, where: l.post_id == ^post_id and l.user_id == ^user_id)
    Repo.delete_all(query)
  end


  alias LockedIn.Posts.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(post,user_id,attrs \\ %{}) do
    # post
    # |> Ecto.build_assoc(:comments, user_id: user_id)
    # |> Comment.changeset(attrs)
    # |> Repo.insert()
    Multi.new()
    |> Multi.insert(:comment, Ecto.build_assoc(post, :comments, user_id: user_id) |> Comment.changeset(attrs))
    |> Multi.merge(fn %{comment: comment} ->
      if post.user_id != user_id do
        Multi.new()
        |>
        Multi.insert(:notification,comment |> Ecto.build_assoc(:notification, %{
          comment_id: comment.id,
          sender_id: user_id,
          recipient_id: post.user_id,
          post_id: post.id
          }))
      else
        Multi.new()
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{comment: comment}} ->
        IO.inspect(comment)
        {:ok,comment}
      {:error, _} ->
        {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
