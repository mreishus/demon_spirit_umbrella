# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

##
## Removed database_url and config of DemonSpirit.Repo,
## Since the DB is removed -MR 9/27/19
## 

# database_url =
#   System.get_env("DATABASE_URL") ||
#     raise """
#     environment variable DATABASE_URL is missing.
#     For example: ecto://USER:PASS@HOST/DATABASE
#     """

# config :demon_spirit, DemonSpirit.Repo,
#   # ssl: true,
#   url: database_url,
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :demon_spirit_web, DemonSpiritWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

### Begin Dashboard Auth ###
# Set Username/Password for Dashboard Basic Auth (/dashboard)
#
# Read from env variables DASH_BASIC_USER and DASH_BASIC_PASS
# If none is set, instead of refusing to run, simply set to random strings.
defmodule ReleaseUtil do
  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end

# Note: This doesn't actually work.
# Spent a lot of time on it and I'm stuck..
dash_basic_username = System.get_env("DASH_BASIC_USER") || ReleaseUtil.random_string(32)
dash_basic_password = System.get_env("DASH_BASIC_PASS") || ReleaseUtil.random_string(32)

config :demon_spirit_web, :dash_basic_auth,
  username: dash_basic_username,
  password: dash_basic_password

### End Dashboard Auth ###

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :demon_spirit_web, DemonSpiritWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
