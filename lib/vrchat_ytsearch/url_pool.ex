defmodule VrchatYtsearch.UrlPool do
  @moduledoc """
  Pool de URLs indexadas para VRChat.

  VRChat no permite crear VRCUrl en runtime, así que pre-asignamos
  500 slots en Unity (pool[0..499] → /play/0../play/499).
  Cuando llegan resultados de búsqueda, asignamos índices del pool
  y guardamos el mapeo index → youtube_url en ETS con TTL de 30 min.

  Uso:
    UrlPool.assign(results)  → [%{..., vrcurl: 0}, %{..., vrcurl: 1}, ...]
    UrlPool.get_url(42)      → "https://www.youtube.com/watch?v=XYZ"
  """

  use GenServer

  @pool_size    500
  @ttl_seconds  1800   # 30 minutos
  @table        :vrc_url_pool

  # ── API pública ────────────────────────────────────────────

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @doc "Asigna índices del pool a una lista de resultados. Devuelve la lista con :vrcurl añadido."
  def assign(results) when is_list(results) do
    GenServer.call(__MODULE__, {:assign, results})
  end

  @doc "Devuelve la YouTube URL para un índice dado, o nil si expiró / no existe."
  def get_url(index) when is_integer(index) do
    now = System.system_time(:second)
    case :ets.lookup(@table, index) do
      [{^index, url, expires_at}] when expires_at > now -> {:ok, url}
      _ -> :not_found
    end
  end

  # ── GenServer ──────────────────────────────────────────────

  def init(_) do
    :ets.new(@table, [:named_table, :public, read_concurrency: true])
    {:ok, %{next_index: 0}}
  end

  def handle_call({:assign, results}, _from, %{next_index: start} = state) do
    expires_at = System.system_time(:second) + @ttl_seconds
    count = length(results)

    # Asignar índices secuenciales con wraparound
    {indexed, new_next} =
      Enum.map_reduce(results, start, fn result, idx ->
        slot = rem(idx, @pool_size)
        :ets.insert(@table, {slot, result.url, expires_at})
        {Map.put(result, :vrcurl, slot), idx + 1}
      end)

    # Limpiar entradas expiradas cada ~10 búsquedas (cheap)
    if rem(new_next, 10 * count) < count, do: cleanup_expired()

    {:reply, indexed, %{state | next_index: rem(new_next, @pool_size)}}
  end

  defp cleanup_expired do
    now = System.system_time(:second)
    :ets.select_delete(@table, [{{:_, :_, :"$1"}, [{:<, :"$1", now}], [true]}])
  end
end
