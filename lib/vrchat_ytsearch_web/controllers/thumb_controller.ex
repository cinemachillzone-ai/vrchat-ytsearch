defmodule VrchatYtsearchWeb.ThumbController do
  use VrchatYtsearchWeb, :controller

  alias VrchatYtsearch.UrlPool

  @doc """
  GET /thumb/:index
  Descarga el thumbnail de YouTube y lo devuelve directamente como image/jpeg.
  VRCImageDownloader no soporta más de 1-2 redirects, así que hacemos proxy aquí.
  """
  def redirect_to_thumb(conn, %{"index" => index_str}) do
    case Integer.parse(index_str) do
      {index, ""} ->
        case UrlPool.get_thumb(index) do
          {:ok, url} when url != "" ->
            case :httpc.request(:get, {String.to_charlist(url), []}, [{:timeout, 5000}], [{:body_format, :binary}]) do
              {:ok, {{_, 200, _}, headers, body}} ->
                content_type =
                  headers
                  |> Enum.find_value("image/jpeg", fn {k, v} ->
                    if String.downcase(List.to_string(k)) == "content-type", do: List.to_string(v)
                  end)
                conn
                |> put_resp_content_type(content_type)
                |> put_resp_header("cache-control", "public, max-age=3600")
                |> send_resp(200, body)

              _ ->
                conn
                |> put_status(:bad_gateway)
                |> json(%{ok: false, error: "No se pudo descargar el thumbnail"})
            end

          _ ->
            conn
            |> put_status(:not_found)
            |> json(%{ok: false, error: "Thumbnail #{index} no encontrado o expirado"})
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{ok: false, error: "Índice inválido: #{index_str}"})
    end
  end
end
