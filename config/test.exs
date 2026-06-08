import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :vrchat_ytsearch, VrchatYtsearch.Repo,
  database: Path.expand("../vrchat_ytsearch_test.db", Path.dirname(__ENV__.file)),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vrchat_ytsearch, VrchatYtsearchWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ZFkgZqDLHgvgieXS74CAyPQv8kvY0XlGMsZE8tux85j8zItZn9FizZIuPChSTflD",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
