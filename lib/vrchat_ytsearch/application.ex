defmodule VrchatYtsearch.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VrchatYtsearchWeb.Telemetry,
      VrchatYtsearch.Repo,
      {DNSCluster, query: Application.get_env(:vrchat_ytsearch, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VrchatYtsearch.PubSub},
      # Pool de URLs indexadas para VRChat (ETS + GenServer)
      VrchatYtsearch.UrlPool,
      # Task que corre migraciones DESPUÉS de que el Repo arranca
      {Task, fn -> auto_migrate() end},
      VrchatYtsearchWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: VrchatYtsearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    VrchatYtsearchWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp auto_migrate do
    require Logger
    # Pequeña espera para asegurar que el Repo esté listo
    Process.sleep(500)

    Logger.info("Running migrations...")

    Ecto.Migrator.run(
      VrchatYtsearch.Repo,
      :up,
      all: true
    )

    Logger.info("Migrations complete.")
  rescue
    e -> Logger.warning("Migration warning: #{inspect(e)}")
  end
end
