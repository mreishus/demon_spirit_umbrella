defmodule DemonSpiritWeb.Presence do
  @moduledoc """
  Standard implementation of Phoenix.Presence behaviour.
  See https://hexdocs.pm/phoenix/Phoenix.Presence.html
  """
  use Phoenix.Presence,
    otp_app: :demon_spirit_web,
    pubsub_server: DemonSpiritWeb.PubSub
end
