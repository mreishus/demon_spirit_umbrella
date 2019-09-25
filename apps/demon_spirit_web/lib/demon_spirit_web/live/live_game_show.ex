defmodule DemonSpiritWeb.LiveGameShow do
  use Phoenix.LiveView
  require Logger
  alias DemonSpiritWeb.{Endpoint, GameUIServer, GameView, Presence}
  alias DemonSpiritWeb.Router.Helpers, as: Routes

  def render(assigns) do
    GameView.render("live_show.html", assigns)
  end

  def mount(%{game_name: game_name, guest: guest}, socket) do
    topic = topic_for(game_name)

    if connected?(socket), do: Endpoint.subscribe(topic)
    {:ok, _} = Presence.track(self(), topic, guest.id, guest)

    state = GameUIServer.sit_down_if_possible(game_name, guest)

    if connected?(socket) and state.options.vs == "computer",
      do: :timer.send_interval(2500, self(), :tick)

    notify(topic)

    socket =
      assign(socket,
        game_name: game_name,
        topic: topic,
        state: state,
        guest: guest,
        users: [],
        flip_per: guest == state.black
      )

    {:ok, socket}
  end

  ## Event: "click-square-3-3" (Someone clicked on square (3,3))
  def handle_event(
        "click-square-" <> coords_str,
        _value,
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    {x, y} = extract_coords(coords_str)

    Logger.info("Game #{game_name}: Clicked on piece: #{x} #{y}")
    state = GameUIServer.click(game_name, {x, y}, guest)
    notify(topic)

    {:noreply, assign(socket, state: state, flip_per: guest == state.black)}
  end

  def handle_event(
        "click-ready",
        _value,
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    Logger.info("Game #{game_name}: Someone clicked ready")
    state = GameUIServer.ready(game_name, guest)
    notify(topic)
    {:noreply, assign(socket, state: state)}
  end

  def handle_event(
        "click-not-ready",
        _value,
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    Logger.info("Game #{game_name}: Someone clicked not ready")
    state = GameUIServer.not_ready(game_name, guest)
    notify(topic)
    {:noreply, assign(socket, state: state)}
  end

  def handle_event(
        "click-leave",
        _value,
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    Logger.info("Game #{game_name}: Someone clicked leave")
    state = GameUIServer.stand_up_if_possible(game_name, guest)
    notify(topic)

    socket =
      socket
      |> assign(state: state)
      |> redirect(to: Routes.game_path(socket, :index))

    {:stop, socket}
  end

  defp extract_coords(coords_str) do
    [{x, ""}, {y, ""}] = coords_str |> String.split("-") |> Enum.map(&Integer.parse/1)
    {x, y}
  end

  defp notify(topic) do
    Endpoint.broadcast_from(self(), topic, "state_update", %{})
  end

  defp topic_for(game_name) do
    "game-topic:" <> game_name
  end

  ## Commented out for experiment below

  # def handle_info(
  #       broadcast = %{event: "state_update", topic: broadcast_topic},
  #       socket = %{assigns: %{game_name: game_name, topic: topic}}
  #     )
  #     when broadcast_topic == topic do
  #   state = GameUIServer.state(game_name)
  #   {:noreply, assign(socket, state: state)}
  # end

  ## Experiment: Keep the "topic matching" stuff out of
  ## Handle_info - is it the case whenever handle_info is called
  ## we're already assured the topic is correct? I think it might be.

  # Handle incoming "state_updates": Game state has changed
  def handle_info(
        %{event: "state_update"},
        socket = %{assigns: %{game_name: game_name}}
      ) do
    state = GameUIServer.state(game_name)
    {:noreply, assign(socket, state: state)}
  end

  # Handle "presence_diff", someone joined or left
  def handle_info(%{event: "presence_diff"}, socket = %{assigns: %{topic: topic}}) do
    users =
      Presence.list(topic)
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    {:noreply, assign(socket, users: users)}
  end

  # Handle ":tick", a request to update game state on a timer
  def handle_info(
        :tick,
        socket = %{assigns: %{game_name: game_name}}
      ) do
    state = GameUIServer.state(game_name)
    {:noreply, assign(socket, state: state)}
  end
end
