defmodule DemonSpiritWeb.LiveGameShow do
  use Phoenix.LiveView
  require Logger
  alias DemonSpiritWeb.{Endpoint, GameUIServer, GameView}

  def render(assigns) do
    GameView.render("live_show.html", assigns)
  end

  def mount(%{game_name: game_name, guest: guest}, socket) do
    topic = topic_for(game_name)
    if connected?(socket), do: Endpoint.subscribe(topic)
    state = GameUIServer.sit_down_if_possible(game_name, guest)

    socket = assign(socket, game_name: game_name, topic: topic, state: state)
    {:ok, socket}
  end

  def handle_event("click-square-" <> coords_str, _value, socket = %{assigns: assigns}) do
    [{x, ""}, {y, ""}] = coords_str |> String.split("-") |> Enum.map(&Integer.parse/1)

    Logger.info("Game #{assigns.game_name}: Clicked on piece: #{x} #{y}")
    state = GameUIServer.click(assigns.game_name, {x, y})

    # Tell others
    Endpoint.broadcast_from(self(), assigns.topic, "state_update", %{})

    {:noreply, assign(socket, state: state)}
  end

  defp topic_for(game_name) do
    "game-topic:" <> game_name
  end

  def handle_info(
        broadcast = %{topic: broadcast_topic},
        socket = %{assigns: %{game_name: game_name, topic: topic}}
      )
      when broadcast_topic == topic do
    case broadcast.event do
      "state_update" ->
        state = GameUIServer.state(game_name)
        {:noreply, assign(socket, state: state)}

      _ ->
        {:noreply, socket}
    end
  end
end
