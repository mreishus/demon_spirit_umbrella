defmodule DemonSpiritWeb.Presence do
  use Phoenix.Presence,
    otp_app: :demon_spirit_web,
    pubsub_server: DemonSpiritWeb.PubSub
end
