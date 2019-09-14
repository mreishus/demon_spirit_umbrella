defmodule DemonSpiritWeb.LiveGameShow do
  use Phoenix.LiveView
  alias DemonSpiritGame.{GameServer}

  def render(assigns) do
    DemonSpiritWeb.GameView.render("live_show.html", assigns)
  end

  def mount(%{game_name: game_name}, socket) do
    game_summary = GameServer.game_summary(game_name)

    {:ok,
     assign(socket,
       deploy_step: "Ready!",
       game_name: game_name,
       all_valid_moves: game_summary.all_valid_moves,
       game: game_summary.game
     )}
  end

  def handle_event("click-piece-" <> coords_str, _value, socket) do
    [{x, ""}, {y, ""}] = coords_str |> String.split("-") |> Enum.map(&Integer.parse/1)

    "Clicked on piece: #{x} #{y}" |> IO.inspect(label: "handle_event")
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end
end
