defmodule DemonSpiritWeb.LiveGameShow do
  use Phoenix.LiveView
  alias DemonSpiritGame.{GameServer}

  def render(assigns) do
    DemonSpiritWeb.GameView.render("live_show.html", assigns)
  end

  def mount(%{game_name: game_name}, socket) do
    state = GameServer.state(game_name)
    {:ok, assign(socket, deploy_step: "Ready!", game_name: game_name, state: state)}
  end
end
