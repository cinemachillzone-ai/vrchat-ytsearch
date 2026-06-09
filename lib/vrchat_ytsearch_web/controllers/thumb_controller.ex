defmodule VrchatYtsearchWeb.ThumbController do
  use VrchatYtsearchWeb, :controller

  alias VrchatYtsearch.UrlPool

  @doc """
  GET /thumb/:index
  Redirige al thumbnail de YouTube asignado a ese índice del pool.
  VRCImageDownloader en Unity sigue el redirect 302 y descarga la imagen.
  """
  def redirect_to_thumb(conn, %{"index" => index_str}) do
    case Integer.parse(index_str) do
      {index, ""} ->
        case UrlPool.get_thumb(index) do
          {:ok, url} when url != "" ->
            conn
            |> put_resp_header("location", url)
            |> send_resp(302, "")

          _ ->
            conn
            |> put_status(:not_found)
            |> json(%{ok: false, error: "Thumbnail #{index} no encontrado o expirado (TTL 30 min)"})
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{ok: false, error: "Índice inválido: #{index_str}"})
    end
  end
end
