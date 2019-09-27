defmodule DemonSpirit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # DemonSpirit.Repo # Removing DB for now -MR 9/27/19
    children = []

    Supervisor.start_link(children, strategy: :one_for_one, name: DemonSpirit.Supervisor)
  end
end
