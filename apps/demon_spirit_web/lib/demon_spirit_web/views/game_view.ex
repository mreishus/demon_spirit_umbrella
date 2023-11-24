defmodule DemonSpiritWeb.GameView do
  use DemonSpiritWeb, :view
  alias DemonSpiritWeb.GameUI
  import Phoenix.Component, only: [live_render: 3]

  @doc """
  staging?/1: Given the current gameui, is it in a staging state?
  The staging state is when we are waiting for players to sit down
  and ready up before the game begins.
  """
  def staging?(gameui) do
    GameUI.staging?(gameui)
  end

  @doc """
  needs_clarify?/1: Does the current player need to clarify which move they meant?
  """
  def needs_clarify?(gameui) do
    gameui.moves_need_clarify != nil and length(gameui.moves_need_clarify) > 0
  end

  @doc """
  clarify_moves/1: Get a list of moves a clarifying player can choose from, with index.
  In format:  [ {0, %Card{}}, {1, %Card{}}, ... ]
  """
  def clarify_moves(gameui) do
    if needs_clarify?(gameui) do
      gameui.moves_need_clarify
      |> Enum.with_index()
      |> Enum.map(fn {move, i} -> {i, move.card} end)
    else
      []
    end
  end

  @doc """
  show_ready_button?/1: Given a gameui state and a player, should
  they see the ready button?
  """
  def show_ready_button?(gameui, guest) do
    cond do
      staging?(gameui) and gameui.black == guest and not gameui.black_ready ->
        true

      staging?(gameui) and gameui.white == guest and not gameui.white_ready ->
        true

      true ->
        false
    end
  end

  @doc """
  show_ready_button?/1: Given a gameui state and a player, should
  they see the "not ready" button?
  """
  def show_not_ready_button?(gameui, guest) do
    cond do
      staging?(gameui) and gameui.black == guest and gameui.black_ready ->
        true

      staging?(gameui) and gameui.white == guest and gameui.white_ready ->
        true

      true ->
        false
    end
  end

  def sort_gameinfos(gis) do
    gis |> Enum.sort_by(fn g -> {g.status, DateTime.to_iso8601(g.created_at)} end, &>=/2)
  end

  @doc """
  date_to_md/1: Turn a DateTime into a string representing the month and day in UTC.
  """
  def date_to_md(a) do
    "#{a.month}/#{a.day}"
  end

  @doc """
  date_to_hms/1: Turn a DateTime into a string representing the hour and minute in UTC.
  """
  def date_to_hms(a) do
    "#{a.hour}:#{zero_pad(a.minute)}"
  end

  # Zero_pad: Given an integer and an amount, pad left with 0s. 
  # Returns string. zero_pad(1, 2) = "01". zero_pad(1, 3) = "001".
  @spec zero_pad(integer(), non_neg_integer()) :: String.t()
  def zero_pad(number, amount \\ 2) do
    number
    |> Integer.to_string()
    |> String.pad_leading(amount, "0")
  end

  def display_ms(ms) do
    seconds = ms / 1000
    seconds_int = trunc(seconds)
    # seconds_leftover = seconds - seconds_int
    {minutes_int, seconds_int_rem} = {div(seconds_int, 60), rem(seconds_int, 60)}
    "#{minutes_int}:#{zero_pad(seconds_int_rem, 2)}"
  end

  @doc """
  game_row_class/1: Returns the appropriate CSS class for a game row based on the game's status.
  """
  def game_row_class(game) do
    case game.status do
      :playing -> "bg-blue-200"
      :staging -> "bg-blue-100"
      :done -> "bg-blue-200"
      _ -> "bg-blue-300"
    end
  end

  def phx_click_value(x, y) do
    "click-square-#{x}-#{y}"
  end

  def piece_style(x, y, flip_per) do
    if flip_per do
      "transform: translate(#{(4 - x) * 100}%, #{y * 100}%);"
    else
      "transform: translate(#{x * 100}%, #{(4 - y) * 100}%);"
    end
  end

  def square_class(x, y, state, my_turn) do
    base_class = "cursor-pointer absolute square"
    selected_class = if my_turn and {x, y} == state.selected, do: " selected", else: ""
    move_dest_class = if my_turn and {x, y} in state.move_dest, do: " move_dest", else: ""
    also_piece_class = if Map.has_key?(state.game.board, {x, y}), do: " also_piece", else: ""

    last_move_class =
      if state.last_move != nil and
           (state.last_move.from == {x, y} or state.last_move.to == {x, y}),
         do: " last_move",
         else: ""

    base_class <> selected_class <> move_dest_class <> also_piece_class <> last_move_class
  end
end
