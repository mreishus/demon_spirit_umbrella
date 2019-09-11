defmodule DemonSpiritGame.GameWinCheck do
  @moduledoc """
  Checks a DemonSpiritGame.Game for a winner and returns
  a copy of the game with the winner set if applicable.
  """
  alias DemonSpiritGame.{Game}

  @doc """
  check/1: Looks for a winner in a Game and
  sets the :winner key if needed.
  Input: %Game{}
  Output: %Game{}
  """
  @spec check(%Game{}) :: %Game{}
  def check(game) do
    game
    |> check_winner_kings()
    |> check_winner_temple()
  end

  _ = """
  check_winner_kings/1: Looks for a winner in a Game and
  sets the :winner key if needed.

  Only checks the condition of a king being killed.
  :winner set to :error in the case that both kings are missing.

  Input: %Game{}
  Output: %Game{}, possibly with :winner set to :white or :black
  """

  @spec check_winner_kings(%Game{}) :: %Game{}
  defp check_winner_kings(game) do
    king_colors =
      game.board
      |> Map.values()
      |> Enum.filter(fn p -> p.type == :king end)
      |> Enum.map(fn p -> p.color end)

    white_missing = :white not in king_colors
    black_missing = :black not in king_colors

    cond do
      white_missing && black_missing ->
        game |> mark_winner(:error)

      white_missing ->
        game |> mark_winner(:black)

      black_missing ->
        game |> mark_winner(:white)

      true ->
        game
    end
  end

  _ = """
  check_winner_kings/1: Looks for a winner in a Game and
  """

  defp check_winner_temple(game) do
    black_ascended = game.board[{2, 0}] == %{color: :black, type: :king}
    white_ascended = game.board[{2, 4}] == %{color: :white, type: :king}

    cond do
      white_ascended && black_ascended ->
        game |> mark_winner(:error)

      white_ascended ->
        game |> mark_winner(:white)

      black_ascended ->
        game |> mark_winner(:black)

      true ->
        game
    end
  end

  defp mark_winner(game = %Game{winner: winner}, _) when not is_nil(winner), do: game

  defp mark_winner(game, color) do
    %Game{game | winner: color}
  end
end
