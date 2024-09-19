defmodule LockedIn.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias LockedIn.Accounts.Connection
  alias LockedIn.Posts.Post
  alias LockedIn.Accounts.User
  alias LockedIn.Posts.Like

  @derive {Jason.Encoder, only: [:id, :email, :firstname, :lastname, :phone, :posts , :comments, :likes, :jobs, :connections_join, :reverse_connections_join, :education, :experience, :skills]}
  schema "users" do
    field :email, :string
    field :password, :string
    field :hashed_password, :string, virtual: true, redact: true #todo: remove field
    field :firstname, :string
    field :lastname, :string
    field :pfp, :string
    field :phone, :string
    field :current_password, :string, virtual: true, redact: true #todo: remove field
    field :status, :string, default: nil, virtual: true
    field :confirmed_at, :utc_datetime #todo: remove field
    has_many :connections_join, Connection, foreign_key: :requester_id
    has_many :reverse_connections_join, Connection, foreign_key: :requestee_id
    many_to_many :connections,
      User,
      join_through: Connection,
      join_keys: [requester_id: :id, requestee_id: :id],
      join_where: [has_accepted: true]
    many_to_many :reverse_connections,
      User,
      join_through: Connection,
      join_keys: [requestee_id: :id, requester_id: :id],
      join_where: [has_accepted: true]
    # many_to_many :skills, LockedIn.Skills.Skill, join_through: LockedIn.Accounts.UserSkill, on_replace: :delete
    has_many :user_skills, LockedIn.Accounts.UserSkill, on_replace: :delete
    many_to_many :skills, LockedIn.Skills.Skill, join_through: LockedIn.Accounts.UserSkill, on_replace: :delete
    many_to_many :public_skills, LockedIn.Skills.Skill, join_through: LockedIn.Accounts.UserSkill, join_where: [public: true]
    # many_to_many :public_skills, LockedIn.Skills.Skill, join_through: LockedIn.Accounts.UserSkill, join_where: [public: true]
    has_many :jobs, LockedIn.Jobs.Job
    has_many :applications, LockedIn.Jobs.Application, foreign_key: :applicant_id
    has_many :notifications, LockedIn.Accounts.Notification, foreign_key: :recipient_id, preload_order: [desc: :inserted_at]
    has_many :posts, Post
    has_many :comments, LockedIn.Posts.Comment
    has_many :likes, Like
    has_many :liked_posts, through: [:likes, :post]
    has_many :connection_posts, through: [:connections, :posts]
    has_many :connection_liked_posts, through: [:connections, :liked_posts]
    has_many :reverse_connection_posts, through: [:reverse_connections, :posts]
    has_many :reverse_connection_liked_posts, through: [:reverse_connections, :liked_posts]
    embeds_many :education, LockedIn.Accounts.UserEducation, on_replace: :delete
    embeds_many :experience, LockedIn.Accounts.UserExperience, on_replace: :delete
    # has_many :feed_posts, through: [connections]
    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :firstname, :lastname, :phone])
    |> validate_email(opts)
    |> validate_password(opts)
    # |> validate_required([:firstname, :lastname, :phone])
    # |> validate_
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, _opts) do
    changeset
    |> validate_required([:password])
    # |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    # |> maybe_hash_password(opts)
    |> hash_password
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)
    changeset
    |> validate_length(:password, max: 72, count: :bytes)
    |> put_change(:password, Bcrypt.hash_pwd_salt(password))
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, LockedIn.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
    |> unique_constraint(:email,name: "users_email_index")
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_password(opts)
  end

  def new_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :new_password])
    |> validate_required([:password, :new_password])
    |> verify_password
  end

  def verify_password(changeset) do
    password = get_change(changeset, :password)
    new_password = get_change(changeset, :new_password)

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :password, "is not valid")
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%{password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  def get_user_pfp(user,filename) do
    rel_path = Path.join(to_string(user.id),Enum.join([user.firstname,user.lastname], "_") <> Path.extname(filename))
    url_path = Path.join("/uploads",rel_path)
    %{fullpath: Path.join(LockedIn.upload_dir,rel_path), url_path: url_path}
  end
end


defimpl Saxy.Builder, for: LockedIn.Accounts.User do
  import Saxy.XML

  def build(user) do
    element(
      "User",
      [id: user.id],
      [
        element("Name", [], Enum.join([user.firstname, user.lastname], " ")),
        element("Email", [], user.email),
        element("Phone", [], user.phone),
        element("CV", [],
        [
          element("Education", [count: length(user.education)], user.education),
          element("Experience", [count: length(user.experience)], user.experience),
          element("Skills", [count: length(user.skills)], user.skills),
        ]
        ),
        element("Posts", [], user.posts),
        element("Comments", [], user.comments),
        element("Likes", [], user.likes),
        element("Jobs", [], user.jobs),
        element("Network", [], user.connections_join ++ Enum.map(user.reverse_connections_join, fn connection -> Map.put(connection,:is_reverse,true) end)),
      ]
    )
  end
end
