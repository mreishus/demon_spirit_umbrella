# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :demon_spirit, env: Mix.env()

# Configure Mix tasks and generators
config :demon_spirit,
  ecto_repos: [DemonSpirit.Repo]

config :demon_spirit_web,
  ecto_repos: [DemonSpirit.Repo],
  generators: [context_app: :demon_spirit]

# Configures the endpoint
config :demon_spirit_web, DemonSpiritWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "V2POCUrmSoTzr8ri1xDPLNlDU0cWruIl6kZFJCnssRbPxe471biGMvn70pfmcmpn",
  render_errors: [view: DemonSpiritWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DemonSpiritWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "l5JjWQ6UpCgG+H5FItedIQEjMdxX3QW7"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Basic Auth for /dashboard - :dash_basic_auth - set during runtime in releases.exs
config :demon_spirit_web, :dash_basic_auth,
  username: "admin",
  password: "EyAU6Ax8cyDkVcNA"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
