defmodule DemonSpirit.Repo do
  use Ecto.Repo,
    otp_app: :demon_spirit,
    adapter: Ecto.Adapters.Postgres
end
