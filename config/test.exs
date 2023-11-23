import Config

# Configure your database
# config :demon_spirit, DemonSpirit.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "demon_spirit_test",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :demon_spirit_web, DemonSpiritWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning
