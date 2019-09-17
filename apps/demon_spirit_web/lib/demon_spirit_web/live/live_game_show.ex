defmodule DemonSpiritWeb.LiveGameShow do
  use Phoenix.LiveView
  require Logger
  alias DemonSpiritWeb.{Endpoint, GameUIServer, GameView}
  alias DemonSpiritWeb.GameUIServer.State

  def render(assigns) do
    GameView.render("live_show.html", assigns)
  end

  def mount(%{game_name: game_name}, socket) do
    topic = topic_for(game_name)
    if connected?(socket), do: Endpoint.subscribe(topic)
    state = GameUIServer.state(game_name)

    socket =
      socket
      |> assign(game_name: game_name, topic: topic)
      |> state_assign(state)

    {:ok, socket}
  end

  def handle_event("click-square-" <> coords_str, _value, socket = %{assigns: assigns}) do
    [{x, ""}, {y, ""}] = coords_str |> String.split("-") |> Enum.map(&Integer.parse/1)

    Logger.info("Game #{assigns.game_name}: Clicked on piece: #{x} #{y}")
    state = GameUIServer.click(assigns.game_name, {x, y})

    # Tell others
    Endpoint.broadcast_from(self(), assigns.topic, "state_update", %{})

    # {:noreply, assign(socket, deploy_step: "Starting deploy...")}
    {:noreply, state_assign(socket, state)}
  end

  defp state_assign(socket, state = %State{}) do
    assign(socket, state: state, game: state.game)
  end

  defp state_assign(socket, something) do
    Logger.warn("LiveGameShow: State_assign: Didn't understand what was passed to me.")
    Logger.debug(fn -> "Payload received: #{inspect(something)}" end)
    socket
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
        {:noreply, state_assign(socket, state)}

      _ ->
        {:noreply, socket}
    end
  end
end

# Phoenix.PubSub.broadcast(MyApp.PubSub, "sometopic", :some_event)
# def handle_info(:some_event, socket) ...
# make the topic something specific to that user/resource/etc
# and in mount do if connected?(socket), do: Phoenix.PubSub.subscribe(MyApp.PubSub, topic)
# so if you want to message a user, the topic can be "user:#{user.id}"
# if it’s to report the result of an upload processing thing, you could do a topic “uploads:#{upload.id}“, etc
