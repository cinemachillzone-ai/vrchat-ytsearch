defmodule VrchatYtsearch.Repo do
  use Ecto.Repo,
    otp_app: :vrchat_ytsearch,
    adapter: Ecto.Adapters.SQLite3
end
