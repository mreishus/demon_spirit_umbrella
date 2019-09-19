defmodule DemonSpiritGame.AI do
  # alias DemonSpiritGame.{Game, Card, Move, GameWinCheck}
  alias DemonSpiritGame.{Game}

  def terminal?(%Game{winner: nil}), do: false
  def terminal?(%Game{}), do: true

  def max_player?(%Game{turn: :white}), do: true
  def max_player?(%Game{}), do: false

  def eval(%Game{winner: :white}), do: 1_000_000
  def eval(%Game{winner: :black}), do: -1_000_000

  def eval(game = %Game{}) do
    game.board
    |> Map.values()
    |> Enum.reduce(0, fn %{color: color}, acc -> acc + if color == :white, do: 1, else: -1 end)
  end

  def alphabeta(game, depth) do
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
        if new_info.val > acc.val do
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
        if new_info.val < acc.val do
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

  # White to win in one move
  def example do
    %DemonSpiritGame.Game{
      board: %{
        {0, 0} => %{color: :white, type: :pawn},
        {0, 3} => %{color: :black, type: :pawn},
        {0, 4} => %{color: :black, type: :pawn},
        {1, 0} => %{color: :white, type: :pawn},
        {2, 4} => %{color: :black, type: :king},
        {3, 0} => %{color: :white, type: :pawn},
        {3, 3} => %{color: :white, type: :king},
        {4, 0} => %{color: :white, type: :pawn},
        {4, 4} => %{color: :black, type: :pawn}
      },
      cards: %{
        black: [
          %DemonSpiritGame.Card{
            color: :green,
            id: 1,
            moves: [{0, 2}, {0, -1}],
            name: "Tiger"
          },
          %DemonSpiritGame.Card{
            color: :blue,
            id: 12,
            moves: [{-1, 1}, {-1, -1}, {1, 0}],
            name: "Eel"
          }
        ],
        side: %DemonSpiritGame.Card{
          color: :red,
          id: 16,
          moves: [{1, 1}, {1, -1}, {-1, 0}],
          name: "Cobra"
        },
        white: [
          %DemonSpiritGame.Card{
            color: :blue,
            id: 28,
            moves: [{0, 1}, {-1, 1}, {1, -1}],
            name: "Bear"
          },
          %DemonSpiritGame.Card{
            color: :green,
            id: 5,
            moves: [{-2, 1}, {2, 1}, {-1, -1}, {1, -1}],
            name: "Dragon"
          }
        ]
      },
      game_name: "ephemeral-susquehanna-5655",
      turn: :white,
      winner: nil
    }
  end

  ## AI Move button ( + 153     ai_info = state.game |> AI.alphabeta(7)
  ## Was returning move = nil and crashing
  ## I guess black was about to lose no matter what, so it refused to move
  def example2 do
    %DemonSpiritWeb.GameUI{
      all_valid_moves: [
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 21,
            moves: [{1, 1}, {1, 0}, {1, -1}],
            name: "Fox"
          },
          from: {1, 4},
          to: {0, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 21,
            moves: [{1, 1}, {1, 0}, {1, -1}],
            name: "Fox"
          },
          from: {1, 4},
          to: {0, 4}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 13,
            moves: [{2, 0}, {1, 1}, {-1, -1}],
            name: "Rabbit"
          },
          from: {1, 4},
          to: {0, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 21,
            moves: [{1, 1}, {1, 0}, {1, -1}],
            name: "Fox"
          },
          from: {2, 3},
          to: {1, 2}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 21,
            moves: [{1, 1}, {1, 0}, {1, -1}],
            name: "Fox"
          },
          from: {2, 3},
          to: {1, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 13,
            moves: [{2, 0}, {1, 1}, {-1, -1}],
            name: "Rabbit"
          },
          from: {2, 3},
          to: {0, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 13,
            moves: [{2, 0}, {1, 1}, {-1, -1}],
            name: "Rabbit"
          },
          from: {2, 3},
          to: {1, 2}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 21,
            moves: [{1, 1}, {1, 0}, {1, -1}],
            name: "Fox"
          },
          from: {2, 4},
          to: {1, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 13,
            moves: [{2, 0}, {1, 1}, {-1, -1}],
            name: "Rabbit"
          },
          from: {2, 4},
          to: {0, 4}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 13,
            moves: [{2, 0}, {1, 1}, {-1, -1}],
            name: "Rabbit"
          },
          from: {2, 4},
          to: {1, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 21,
            moves: [{1, 1}, {1, 0}, {1, -1}],
            name: "Fox"
          },
          from: {4, 4},
          to: {3, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :red,
            id: 13,
            moves: [{2, 0}, {1, 1}, {-1, -1}],
            name: "Rabbit"
          },
          from: {4, 4},
          to: {3, 3}
        }
      ],
      black: nil,
      created_at: ~U[2019-09-19 16:27:32.341300Z],
      game: %DemonSpiritGame.Game{
        board: %{
          {1, 1} => %{color: :white, type: :pawn},
          {1, 4} => %{color: :black, type: :pawn},
          {2, 0} => %{color: :white, type: :king},
          {2, 2} => %{color: :white, type: :pawn},
          {2, 3} => %{color: :black, type: :pawn},
          {2, 4} => %{color: :black, type: :king},
          {3, 0} => %{color: :white, type: :pawn},
          {3, 4} => %{color: :black, type: :pawn},
          {4, 0} => %{color: :white, type: :pawn},
          {4, 4} => %{color: :black, type: :pawn}
        },
        cards: %{
          black: [
            %DemonSpiritGame.Card{
              color: :red,
              id: 21,
              moves: [{1, 1}, {1, 0}, {1, -1}],
              name: "Fox"
            },
            %DemonSpiritGame.Card{
              color: :red,
              id: 13,
              moves: [{2, 0}, {1, 1}, {-1, -1}],
              name: "Rabbit"
            }
          ],
          side: %DemonSpiritGame.Card{
            color: :blue,
            id: 31,
            moves: [{0, 1}, {-2, 1}, {1, -1}],
            name: "Iguana"
          },
          white: [
            %DemonSpiritGame.Card{
              color: :green,
              id: 19,
              moves: [{-2, 0}, {2, 0}, {-1, 1}, {1, 1}],
              name: "Phoenix"
            },
            %DemonSpiritGame.Card{
              color: :green,
              id: 1,
              moves: [{0, 2}, {0, -1}],
              name: "Tiger"
            }
          ]
        },
        game_name: "incipient-imbroglio-4891",
        turn: :black,
        winner: nil
      },
      game_name: "incipient-imbroglio-4891",
      last_move: nil,
      move_dest: [],
      selected: nil,
      state: nil,
      white: nil
    }
  end

  ## Another one where black refuses to move
  def example3 do
    %DemonSpiritWeb.GameUI{
      all_valid_moves: [
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 3,
            moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
            name: "Monkey"
          },
          from: {3, 2},
          to: {4, 1}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 3,
            moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
            name: "Monkey"
          },
          from: {3, 2},
          to: {2, 1}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 3,
            moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
            name: "Monkey"
          },
          from: {3, 2},
          to: {2, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 17,
            moves: [{0, -1}, {-2, 1}, {2, 1}],
            name: "Giraffe"
          },
          from: {3, 2},
          to: {3, 3}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 17,
            moves: [{0, -1}, {-2, 1}, {2, 1}],
            name: "Giraffe"
          },
          from: {3, 2},
          to: {1, 1}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 3,
            moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
            name: "Monkey"
          },
          from: {4, 3},
          to: {3, 4}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 17,
            moves: [{0, -1}, {-2, 1}, {2, 1}],
            name: "Giraffe"
          },
          from: {4, 3},
          to: {4, 4}
        },
        %DemonSpiritGame.Move{
          card: %DemonSpiritGame.Card{
            color: :green,
            id: 17,
            moves: [{0, -1}, {-2, 1}, {2, 1}],
            name: "Giraffe"
          },
          from: {4, 3},
          to: {2, 2}
        }
      ],
      black: nil,
      created_at: ~U[2019-09-19 16:34:47.329686Z],
      game: %DemonSpiritGame.Game{
        board: %{
          {0, 4} => %{color: :white, type: :king},
          {3, 2} => %{color: :black, type: :pawn},
          {4, 1} => %{color: :white, type: :pawn},
          {4, 3} => %{color: :black, type: :king}
        },
        cards: %{
          black: [
            %DemonSpiritGame.Card{
              color: :green,
              id: 3,
              moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
              name: "Monkey"
            },
            %DemonSpiritGame.Card{
              color: :green,
              id: 17,
              moves: [{0, -1}, {-2, 1}, {2, 1}],
              name: "Giraffe"
            }
          ],
          side: %DemonSpiritGame.Card{
            color: :blue,
            id: 10,
            moves: [{-1, 1}, {-1, 0}, {1, 0}, {1, -1}],
            name: "Goose"
          },
          white: [
            %DemonSpiritGame.Card{
              color: :green,
              id: 2,
              moves: [{0, 1}, {-2, 0}, {2, 0}],
              name: "Crab"
            },
            %DemonSpiritGame.Card{
              color: :blue,
              id: 28,
              moves: [{0, 1}, {-1, 1}, {1, -1}],
              name: "Bear"
            }
          ]
        },
        game_name: "summery-susquehanna-6049",
        turn: :black,
        winner: nil
      },
      game_name: "summery-susquehanna-6049",
      last_move: nil,
      move_dest: [],
      selected: nil,
      state: nil,
      white: nil
    }
  end
end

# alias DemonSpiritGame.{AI, GameServer}
# AI.example() |> AI.alphabeta(4)

# GameServer.start_link("aaa")
# GameServer.state("aaa") |> AI.alphabeta(4)
