defmodule VrchatYtsearchWeb.SearchController do
  use VrchatYtsearchWeb, :controller

  alias VrchatYtsearch.Search

  @doc """
  GET /search?q=lofi+hip+hop
  Devuelve 6 resultados de YouTube en JSON.
  """
  def index(conn, %{"q" => query}) when byte_size(query) > 0 do
    case Search.search(query) do
      {:ok, results} ->
        json(conn, %{
          ok:      true,
          query:   query,
          count:   length(results),
          results: results
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{ok: false, error: reason})
    end
  end

  def index(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{ok: false, error: "Parámetro 'q' requerido. Ejemplo: /search?q=lofi"})
  end
end
