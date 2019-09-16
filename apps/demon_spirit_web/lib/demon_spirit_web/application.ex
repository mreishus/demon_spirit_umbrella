defmodule DemonSpiritWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      DemonSpiritWeb.Endpoint,
      # Starts a worker by calling: DemonSpiritWeb.Worker.start_link(arg)
      # {DemonSpiritWeb.Worker, arg},
      {Registry, keys: :unique, name: DemonSpiritWeb.GameUIRegistry},
      DemonSpiritWeb.GameUISupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemonSpiritWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DemonSpiritWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
