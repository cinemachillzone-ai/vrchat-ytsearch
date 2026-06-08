defmodule VrchatYtsearchWeb.HealthController do
  use VrchatYtsearchWeb, :controller

  def index(conn, _params) do
    json(conn, %{ok: true, service: "vrchat-ytsearch", version: "1.0.0"})
  end
end
