defmodule LockedIn.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @impl true
  def start(_type, _args) do
    children = [
      LockedInWeb.Telemetry,
      LockedIn.Repo,
      {DNSCluster, query: Application.get_env(:locked_in, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LockedIn.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LockedIn.Finch},
      # Start a worker by calling: LockedIn.Worker.start_link(arg)
      # {LockedIn.Worker, arg},
      # Start to serve requests, typically the last entry
      LockedInWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LockedIn.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LockedInWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def start_phase(:ensure_upload_dir, :normal, _phase_args) do
    upload_dir = LockedIn.upload_dir()
    File.mkdir_p!(upload_dir)
    :ok
  end

  def start_phase(:create_admin, :normal, _phase_args) do
    case LockedIn.Accounts.get_user_by_email("admin") do
      nil ->
        {:ok, _admin} = LockedIn.Accounts.create_user(%{
          email: "admin",
          password: Bcrypt.hash_pwd_salt("admin"),
        })
      _user ->
        :ok
    end
    :ok
  end


end
