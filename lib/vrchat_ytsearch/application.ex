defmodule VrchatYtsearch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Ejecutar migraciones automáticamente al arrancar (necesario en Render)
    auto_migrate()

    children = [
      VrchatYtsearchWeb.Telemetry,
      VrchatYtsearch.Repo,
      {DNSCluster, query: Application.get_env(:vrchat_ytsearch, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VrchatYtsearch.PubSub},
      # Start a worker by calling: VrchatYtsearch.Worker.start_link(arg)
      # {VrchatYtsearch.Worker, arg},
      # Start to serve requests, typically the last entry
      VrchatYtsearchWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VrchatYtsearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VrchatYtsearchWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp auto_migrate do
    Ecto.Migrator.run(
      VrchatYtsearch.Repo,
      :up,
      all: true
    )
  rescue
    e -> require Logger; Logger.warning("Migration warning: #{inspect(e)}")
  end
end
