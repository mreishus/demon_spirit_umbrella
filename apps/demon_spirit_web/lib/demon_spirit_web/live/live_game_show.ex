defmodule DemonSpiritWeb.LiveGameShow do
  use Phoenix.LiveView
  alias DemonSpiritWeb.Endpoint
  alias DemonSpiritWeb.GameUIServer
  alias DemonSpiritWeb.GameUIServer.State

  def render(assigns) do
    DemonSpiritWeb.GameView.render("live_show.html", assigns)
  end

  def mount(%{game_name: game_name}, socket) do
    if connected?(socket), do: Endpoint.subscribe(topic_for(game_name))
    state = GameUIServer.state(game_name)

    socket =
      socket
      |> assign(game_name: game_name, topic: topic_for(game_name))
      |> state_assign(state)

    {:ok, socket}
  end

  def handle_event("click-piece-" <> coords_str, _value, socket = %{assigns: assigns}) do
    [{x, ""}, {y, ""}] = coords_str |> String.split("-") |> Enum.map(&Integer.parse/1)

    "Clicked on piece: #{x} #{y}" |> IO.inspect(label: "handle_event")
    state = GameUIServer.click(assigns.game_name, {x, y})

    # Tell others
    Endpoint.broadcast_from(self(), topic_for(assigns.game_name), "state_update", %{})

    # assigns |> IO.inspect(label: "assigns")
    # {:noreply, assign(socket, deploy_step: "Starting deploy...")}
    {:noreply, state_assign(socket, state)}
  end

  defp state_assign(socket, state = %State{}) do
    assign(socket, state: state, game: state.game)
  end

  defp state_assign(socket, something) do
    IO.puts("LiveGameShow: State_assign: Didn't understand what was passed to me.")
    something |> IO.inspect()
    socket
  end

  defp topic_for(game_name) do
    "game-topic:" <> game_name
  end

  def handle_info(broadcast = %{topic: "game-topic:" <> topic_game_name}, socket) do
    game_name = socket.assigns.game_name

    if topic_game_name == game_name do
      case broadcast.event do
        "state_update" ->
          state = GameUIServer.state(game_name)
          {:noreply, state_assign(socket, state)}

        _ ->
          {:noreply, socket}
      end
    else
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
