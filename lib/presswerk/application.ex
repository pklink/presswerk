defmodule Presswerk.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @doc "Starts the application supervisor with all child processes."
  @impl true
  def start(_type, _args) do
    children = [
      PresswerkWeb.Telemetry,
      Presswerk.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:presswerk, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:presswerk, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Presswerk.PubSub},
      # Start a worker by calling: Presswerk.Worker.start_link(arg)
      # {Presswerk.Worker, arg},
      # Start to serve requests, typically the last entry
      PresswerkWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Presswerk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @doc "Handles application configuration changes at runtime."
  @impl true
  def config_change(changed, _new, removed) do
    PresswerkWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
