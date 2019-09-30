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
    tick_ref = create_tick_interval(socket, state)

    notify(topic)

    socket =
      assign(socket,
        game_name: game_name,
        topic: topic,
        state: state,
        guest: guest,
        users: [],
        flip_per: guest == state.black,
        tick_ref: tick_ref
      )

    {:ok, socket}
  end

  # If playing against the computer, create a timer that automatically sends
  # ":tick" messages, so I am constantly updating the game state.
  # If we can get the AI to publish an "update state" message over the 
  # pubsub channel, then we can remove this.
  defp create_tick_interval(socket, state) do
    {:ok, tick_ref} =
      if connected?(socket) and state.options.vs == "computer" do
        :timer.send_interval(2500, self(), :tick)
      else
        {:ok, nil}
      end

    tick_ref
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

  def handle_event(
        "drag-piece",
        %{"sx" => sx, "sy" => sy},
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    state = GameUIServer.drag_start(game_name, {sx, sy}, guest)
    notify(topic)
    {:noreply, assign(socket, state: state)}
  end

  def handle_event(
        "drag-end",
        _val,
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    state = GameUIServer.drag_end(game_name, guest)
    notify(topic)
    {:noreply, assign(socket, state: state)}
  end

  def handle_event(
        "drop-piece",
        %{"sx" => sx, "sy" => sy, "tx" => tx, "ty" => ty},
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    state = GameUIServer.drag_drop(game_name, {sx, sy}, {tx, ty}, guest)
    notify(topic)
    {:noreply, assign(socket, state: state)}
  end

  def handle_event(
        "clarify-move",
        %{"i" => i},
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    {i, ""} = Integer.parse(i)
    state = GameUIServer.clarify_move(game_name, i, guest)
    notify(topic)
    {:noreply, assign(socket, state: state)}
  end

  def handle_event(
        "cancel-clarify",
        _val,
        socket = %{assigns: %{game_name: game_name, guest: guest, topic: topic}}
      ) do
    state = GameUIServer.clarify_cancel(game_name, guest)
    notify(topic)
    {:noreply, assign(socket, state: state)}
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
        socket = %{assigns: %{game_name: game_name, tick_ref: tick_ref}}
      ) do
    state = GameUIServer.state(game_name)

    if tick_ref != nil and stop_ticking?(state) do
      :timer.cancel(tick_ref)
    end

    {:noreply, assign(socket, state: state)}
  end

  # There's a winner or game has been alive for a long time
  defp stop_ticking?(state) do
    state.game.winner != nil or game_alive_too_long?(state)
  end

  # Game alive more than 4 hours
  defp game_alive_too_long?(game_state) do
    DateTime.diff(DateTime.utc_now(), game_state.created_at) > 60 * 60 * 4
  end
end
