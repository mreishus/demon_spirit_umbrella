defmodule DemonSpiritWeb.LiveGameIndex do
  use Phoenix.LiveView
  require Logger
  alias DemonSpiritWeb.{Endpoint, GameRegistry, GameView}

  @topic "game-registry"

  def render(assigns) do
    GameView.render("live_index.html", assigns)
  end

  def mount(_params, socket) do
    if connected?(socket), do: Endpoint.subscribe(@topic)
    games = GameRegistry.list()
    {:ok, assign(socket, games: games)}
  end

  def handle_info({:state_update, _map}, socket) do
    games = GameRegistry.list()
    {:noreply, assign(socket, games: games)}
  end
end
