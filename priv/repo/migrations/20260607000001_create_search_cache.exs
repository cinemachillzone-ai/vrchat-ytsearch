defmodule VrchatYtsearch.Repo.Migrations.CreateSearchCache do
  use Ecto.Migration

  def change do
    create table(:search_cache) do
      add :query,      :string,  null: false
      add :results,    :text,    null: false  # JSON serializado
      add :expires_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:search_cache, [:query])
  end
end
