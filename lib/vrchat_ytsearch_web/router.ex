defmodule VrchatYtsearchWeb.Router do
  use VrchatYtsearchWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  # Endpoint principal de búsqueda
  # GET /search?q=tu+busqueda
  scope "/", VrchatYtsearchWeb do
    pipe_through :api

    get "/search",       SearchController, :index
    get "/health",       HealthController, :index
    get "/play/:index",  PlayController,   :redirect_to_video
  end
end
