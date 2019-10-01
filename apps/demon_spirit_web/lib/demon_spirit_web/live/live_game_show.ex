defmodule DemonSpiritWeb.LiveGameShow do
  @moduledoc """
  LiveGameShow:  This is the liveView of the "show" action of the game controller.
  If you are watching or playing a game, you're using this module.
  """
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

  def notify(topic) do
    Endpoint.broadcast_from(self(), topic, "state_update", %{})
  end

  def topic_for(game_name) do
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
end
