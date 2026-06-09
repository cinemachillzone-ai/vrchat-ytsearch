defmodule VrchatYtsearchWeb.PlayController do
  use VrchatYtsearchWeb, :controller

  alias VrchatYtsearch.UrlPool

  @doc """
  GET /play/:index
  Redirige al YouTube URL asignado a ese índice del pool.
  VRChat sigue el redirect 302 y reproduce el video.
  """
  def redirect_to_video(conn, %{"index" => index_str}) do
    case Integer.parse(index_str) do
      {index, ""} ->
        case UrlPool.get_url(index) do
          {:ok, url} ->
            conn
            |> put_resp_header("location", url)
            |> send_resp(302, "")

          :not_found ->
            conn
            |> put_status(:not_found)
            |> json(%{ok: false, error: "Índice #{index} no encontrado o expirado (TTL 30 min)"})
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{ok: false, error: "Índice inválido: #{index_str}"})
    end
  end
end
