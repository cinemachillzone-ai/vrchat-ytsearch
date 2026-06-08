defmodule VrchatYtsearch.SearchCache do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_cache" do
    field :query,      :string
    field :results,    :string   # JSON string
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(cache, attrs) do
    cache
    |> cast(attrs, [:query, :results, :expires_at])
    |> validate_required([:query, :results, :expires_at])
    |> unique_constraint(:query)
  end
end
