defmodule DemonSpiritGame.AI do
  alias DemonSpiritGame.Game

  # terminal?/1: Is this game in a terminal state? Boolean
  # (Is there a winner)
  defp terminal?(%Game{winner: nil}), do: false
  defp terminal?(%Game{}), do: true

  # max_player?/1: Is the current player trying to maximize score? Boolean
  # White is trying to maximize, black is trying to minimize.
  defp max_player?(%Game{turn: :white}), do: true
  defp max_player?(%Game{}), do: false

  # eval/1: Return score of current game.  A won game is either + or -
  # 1 million points, positive if white won, negative if black won.
  # A non won-game is how many pieces up/down that player is.
  # If white has 5 pieces and black has 3, score is 2.
  # If black has 5 pieces and white has 1, score is -4.
  defp eval(%Game{winner: :white}), do: 1_000_000
  defp eval(%Game{winner: :black}), do: -1_000_000

  defp eval(game = %Game{}) do
    game.board
    |> Map.values()
    |> Enum.reduce(0, fn %{color: color}, acc -> acc + if color == :white, do: 1, else: -1 end)
  end

  # eval_skill/2: Return score of current game, but adjusted for skill level (1-100).
  # The lower the skill level of the AI, the more incorrect the score will be.
  # If skill level is 30, we use (real score * 0.30) + (random score * 0.70).
  defp eval_skill(game = %Game{}, 100), do: eval(game)

  defp eval_skill(game = %Game{}, skill) when is_integer(skill) and skill >= 0 and skill <= 100 do
    real_eval = eval(game)

    # Random between -6 and 6
    # fake_eval = :rand.uniform(13) - 7
    # Normal distribution, 2sd = -4.5 to 4.5, 3sd = -6.75 to 6.75, but rounded
    fake_eval = :rand.normal() * 2

    a = round(skill / 100 * real_eval + (100 - skill) / 100 * fake_eval)
    # "Eval_skill: skill[#{skill}] real eval[#{real_eval}] --> a[#{a}]" |> IO.inspect()
    a
  end

  @doc """
  alphabeta_skill/2:  Run a mixmax a b prune search on game to find the next move, but
  give the AI a skill level (1-100).  The lower skill, the poorer quality moves.
  Skill affects search depth, game state evaluation, and # of moves considered.
  """
  def alphabeta_skill(game, skill) when is_integer(skill) and skill >= 0 and skill <= 100 do
    depth = skill_to_depth(skill)
    alphabeta(game, depth, -1_000_000, 1_000_000, skill)
  end

  # skill_to_depth/1: Given a skill number 1-100, return a search depth to use.
  # We simply linerally rescale skill 1-100 to depth 2-8.
  defp skill_to_depth(skill) do
    # Depth 10 is just a little too slow, can take multiple minutes
    remap(skill, {0, 100}, {2, 8}) |> round()
  end

  # remap/3: Remap a number on one scale to another.
  # Example: remap(50, {0, 100}, {0, 1000}) = 500
  defp remap(x, {in_min, in_max}, {out_min, out_max}) do
    (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end

  # transform_moves_skill/2: Given a list of moves and a skill rating (1-100),
  # return which moves should be searched.  At skill ratings below 70, we randomly
  # drop moves to be searched.
  defp transform_moves_skill(moves, 100), do: moves
  defp transform_moves_skill(moves, skill) when skill > 70, do: moves

  defp transform_moves_skill(moves, skill) do
    max_moves = length(moves)

    # min_moves = 1 # Lowest skill sees 1 random move
    # Lowest skill sees 45% of all moves, can't go below 1
    min_moves = (length(moves) * 0.45) |> round() |> max(1)

    # At skill >= skill_max, we see all moves
    skill_max = 70
    skill = min(skill_max, skill)
    num_moves = remap(skill, {0, skill_max}, {min_moves, max_moves}) |> round()

    # "Transform moves: skill[#{skill}] num moves[#{max_moves}}] moves considered[#{num_moves}]"
    # |> IO.inspect()

    if num_moves >= max_moves do
      moves
    else
      Enum.take_random(moves, num_moves)
    end
  end

  # alphabeta/2: Do minimax w/ alpha-beta pruning AI search for the best
  # move to play.  Will consider `depth` number of moves.
  # For a brand new game, on my laptop
  # 9 - 4 seconds
  # 10 - 17 seconds
  # 11 - 1 minute 15 seconds
  # 12 - 5 minutes
  def alphabeta(game, depth) when is_integer(depth) do
    alphabeta(game, depth, -1_000_000, 1_000_000, 100)
  end

  def alphabeta(game, depth, a, b, skill)
      when is_integer(skill) and skill >= 0 and skill <= 100 do
    cond do
      depth == 0 or terminal?(game) -> %{val: eval_skill(game, skill), move: nil, a: a, b: b}
      max_player?(game) -> alphabeta_max(game, depth, a, b, skill)
      true -> alphabeta_min(game, depth, a, b, skill)
    end
  end

  defp alphabeta_max(game, depth, a, b, skill)
       when is_integer(skill) and skill >= 0 and skill <= 100 do
    initial_acc = %{
      val: -1_000_000,
      move: nil,
      a: a,
      b: b
    }

    game
    |> Game.all_valid_moves()
    |> transform_moves_skill(skill)
    |> Enum.reduce_while(initial_acc, fn move, acc ->
      {:ok, new_game} = Game.move(game, move)
      new_info = alphabeta(new_game, depth - 1, acc.a, acc.b, skill)

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

  defp alphabeta_min(game, depth, a, b, skill)
       when is_integer(skill) and skill >= 0 and skill <= 100 do
    initial_acc = %{
      val: 1_000_000,
      move: nil,
      a: a,
      b: b
    }

    game
    |> Game.all_valid_moves()
    |> transform_moves_skill(skill)
    |> Enum.reduce_while(initial_acc, fn move, acc ->
      {:ok, new_game} = Game.move(game, move)
      new_info = alphabeta(new_game, depth - 1, acc.a, acc.b, skill)

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
