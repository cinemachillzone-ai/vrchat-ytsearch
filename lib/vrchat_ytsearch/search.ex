defmodule VrchatYtsearch.Search do
  @moduledoc """
  Lógica de búsqueda con caché en SQLite.
  TTL de 1 hora por query.
  """

  import Ecto.Query
  alias VrchatYtsearch.{Repo, SearchCache, Ytdlp}

  @cache_ttl_seconds 3600  # 1 hora

  @doc """
  Busca videos. Primero revisa caché, si no llama a yt-dlp.
  """
  def search(query) when is_binary(query) do
    normalized = String.downcase(String.trim(query))

    case get_cached(normalized) do
      {:hit, results} ->
        {:ok, results}

      :miss ->
        fetch_and_cache(normalized)
    end
  end

  # --- Privadas ---

  defp get_cached(query) do
    now = DateTime.utc_now()

    result =
      from(c in SearchCache,
        where: c.query == ^query and c.expires_at > ^now
      )
      |> Repo.one()

    case result do
      nil ->
        :miss

      cached ->
        case Jason.decode(cached.results) do
          {:ok, results} -> {:hit, results}
          _              -> :miss
        end
    end
  end

  defp fetch_and_cache(query) do
    with {:ok, results} <- Ytdlp.search(query),
         {:ok, json}    <- Jason.encode(results) do

      expires_at =
        DateTime.utc_now()
        |> DateTime.add(@cache_ttl_seconds, :second)
        |> DateTime.truncate(:second)

      # Upsert: actualiza si ya existe el query
      Repo.insert!(
        %SearchCache{
          query:      query,
          results:    json,
          expires_at: expires_at
        },
        on_conflict: [set: [results: json, expires_at: expires_at, updated_at: DateTime.utc_now() |> DateTime.truncate(:second)]],
        conflict_target: :query
      )

      {:ok, results}
    end
  end
end
