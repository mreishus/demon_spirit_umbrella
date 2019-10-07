defmodule DemonSpiritWeb.GameTimer do
  alias DemonSpiritGame.{Game}
  alias DemonSpiritWeb.GameTimer
  require Logger

  defstruct white_time: 0,
            white_time_current: 0,
            black_time: 0,
            black_time_current: 0,
            last_move: nil,
            started: false

  def new do
    %GameTimer{
      white_time: 5 * 60 * 1000,
      black_time: 5 * 60 * 1000,
      last_move: nil,
      started: false
    }
  end

  def apply_move(timer = %GameTimer{}, game = %Game{}) do
    if timer.started == false do
      %{timer | started: true, last_move: DateTime.utc_now()}
    else
      apply_move_started(timer, game)
    end
  end

  defp apply_move_started(timer = %GameTimer{}, game = %Game{}) do
    time_elapsed = DateTime.diff(DateTime.utc_now(), timer.last_move, :millisecond)

    case game.turn do
      :white ->
        t = timer.white_time - time_elapsed
        %{timer | white_time: t, white_time_current: t, last_move: DateTime.utc_now()}

      :black ->
        t = timer.black_time - time_elapsed
        %{timer | black_time: t, black_time_current: t, last_move: DateTime.utc_now()}

      _ ->
        Logger.warn("GameTimer: Don't know whose turn it is.")
        %{timer | last_move: DateTime.utc_now()}
    end
  end

  def get_current_time(timer, game) do
    if timer.started == false do
      timer
    else
      get_current_time_started(timer, game)
    end
  end

  defp get_current_time_started(timer = %GameTimer{}, game = %Game{}) do
    time_elapsed = DateTime.diff(DateTime.utc_now(), timer.last_move, :millisecond)

    case game.turn do
      :white ->
        t = timer.white_time - time_elapsed
        %{timer | white_time_current: t}

      :black ->
        t = timer.black_time - time_elapsed
        %{timer | black_time_current: t}

      _ ->
        Logger.warn("GameTimer: Don't know whose turn it is [2].")
        timer
    end
  end
end
