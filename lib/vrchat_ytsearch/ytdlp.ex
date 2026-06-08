defmodule VrchatYtsearch.Ytdlp do
  @moduledoc """
  Wrapper para ejecutar yt-dlp y obtener resultados de búsqueda de YouTube.
  """

  @results_count 6

  @doc """
  Busca videos en YouTube usando yt-dlp.
  Devuelve {:ok, [results]} o {:error, reason}.
  """
  def search(query) do
    search_query = "ytsearch#{@results_count}:#{query}"

    args = [
      "--dump-json",
      "--no-playlist",
      "--no-warnings",
      "--flat-playlist",
      search_query
    ]

    case System.cmd("yt-dlp", args, stderr_to_stdout: false) do
      {output, 0} ->
        results =
          output
          |> String.split("\n", trim: true)
          |> Enum.map(&parse_entry/1)
          |> Enum.reject(&is_nil/1)

        {:ok, results}

      {error, code} ->
        {:error, "yt-dlp falló con código #{code}: #{error}"}
    end
  end

  defp parse_entry(json_line) do
    case Jason.decode(json_line) do
      {:ok, entry} ->
        %{
          title:    Map.get(entry, "title", "Sin título"),
          url:      "https://www.youtube.com/watch?v=#{Map.get(entry, "id", "")}",
          thumbnail: Map.get(entry, "thumbnail") || thumbnail_url(Map.get(entry, "id")),
          duration:  Map.get(entry, "duration", 0),
          channel:   Map.get(entry, "uploader") || Map.get(entry, "channel", "Desconocido"),
          view_count: Map.get(entry, "view_count", 0)
        }

      {:error, _} ->
        nil
    end
  end

  defp thumbnail_url(nil), do: nil
  defp thumbnail_url(id),  do: "https://i.ytimg.com/vi/#{id}/mqdefault.jpg"
end
