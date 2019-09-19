defmodule DemonSpiritGame.AI do
  alias DemonSpiritGame.Game

  # terminal?/1: Is this game in a terminal state? Boolean
  # (Is there a winner)
  def terminal?(%Game{winner: nil}), do: false
  def terminal?(%Game{}), do: true

  # max_player?/1: Is the current player trying to maximize score? Boolean
  # White is trying to maximize, black is trying to minimize.
  def max_player?(%Game{turn: :white}), do: true
  def max_player?(%Game{}), do: false

  # eval/1: Return score of current game.  A won game is either + or -
  # 1 million points, positive if white won, negative if black won.
  # A non won-game is how many pieces up/down that player is.
  # If white has 5 pieces and black has 3, score is 2.
  # If black has 5 pieces and white has 1, score is -4.
  def eval(%Game{winner: :white}), do: 1_000_000
  def eval(%Game{winner: :black}), do: -1_000_000

  def eval(game = %Game{}) do
    game.board
    |> Map.values()
    |> Enum.reduce(0, fn %{color: color}, acc -> acc + if color == :white, do: 1, else: -1 end)
  end

  # alphabeta/2: Do minimax w/ alpha-beta pruning AI search for the best
  # move to play.  Will consider `depth` number of moves.
  # For a brand new game, on my laptop
  # 9 - 4 seconds
  # 10 - 17 seconds
  # 11 - 1 minute 15 seconds
  # 12 - 5 minutes
  def alphabeta(game, depth) when is_integer(depth) do
    alphabeta(game, depth, -1_000_000, 1_000_000)
  end

  def alphabeta(game, depth, a, b) do
    cond do
      depth == 0 or terminal?(game) -> %{val: eval(game), move: nil, a: a, b: b}
      max_player?(game) -> alphabeta_max(game, depth, a, b)
      true -> alphabeta_min(game, depth, a, b)
    end
  end

  def alphabeta_max(game, depth, a, b) do
    initial_acc = %{
      val: -1_000_000,
      move: nil,
      a: a,
      b: b
    }

    game
    |> Game.all_valid_moves()
    |> Enum.reduce_while(initial_acc, fn move, acc ->
      {:ok, new_game} = Game.move(game, move)
      new_info = alphabeta(new_game, depth - 1, acc.a, acc.b)

      # %{
      #   who: "Maximizer",
      #   move: move,
      #   val: acc.val,
      #   acc_move: acc.move,
      #   new_val: new_info.val
      # }
      # |> IO.inspect()

      acc =
        if new_info.val > acc.val or acc.move == nil do
          %{acc | val: new_info.val, move: move}
        else
          acc
        end

      if acc.val >= acc.b do
        {:halt, acc}
      else
        acc = %{acc | a: Enum.max([acc.a, acc.val])}
        {:cont, acc}
      end
    end)
  end

  def alphabeta_min(game, depth, a, b) do
    initial_acc = %{
      val: 1_000_000,
      move: nil,
      a: a,
      b: b
    }

    game
    |> Game.all_valid_moves()
    |> Enum.reduce_while(initial_acc, fn move, acc ->
      {:ok, new_game} = Game.move(game, move)
      new_info = alphabeta(new_game, depth - 1, acc.a, acc.b)

      # %{
      #   who: "Minimizer",
      #   move: move,
      #   val: acc.val,
      #   new_val: new_info.val
      # }
      # |> IO.inspect()

      acc =
        if new_info.val < acc.val or acc.move == nil do
          %{acc | val: new_info.val, move: move}
        else
          acc
        end

      if acc.val <= acc.a do
        {:halt, acc}
      else
        acc = %{acc | b: Enum.min([acc.b, acc.val])}
        {:cont, acc}
      end
    end)
  end
end

# alias DemonSpiritGame.{AI, GameServer}
# AI.example() |> AI.alphabeta(4)

# GameServer.start_link("aaa")
# GameServer.state("aaa") |> AI.alphabeta(4)
