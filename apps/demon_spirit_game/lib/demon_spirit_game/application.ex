defmodule DemonSpiritGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: DemonSpiritGame.GameRegistry}
      # Starts a worker by calling: DemonSpiritGame.Worker.start_link(arg)
      # {DemonSpiritGame.Worker, arg}
    ]

    :ets.new(:games, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemonSpiritGame.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
