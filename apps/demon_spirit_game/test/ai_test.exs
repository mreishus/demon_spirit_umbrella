defmodule AiTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.AI, import: true
  alias DemonSpiritGame.{AI}

  test "example1" do
    ai_info = example1() |> AI.alphabeta(4)
    assert ai_info.val > 1000
    assert ai_info.move.from == {3, 3}
    assert ai_info.move.to == {2, 4}
  end

  test "example2" do
    ai_info = example2() |> AI.alphabeta(4)
    assert ai_info.move != nil
  end

  test "example3" do
    ai_info = example3() |> AI.alphabeta(4)
    assert ai_info.move != nil
  end

  test "example4" do
    ai_info = example4() |> AI.alphabeta(5)
    assert ai_info.val > 1000
    assert ai_info.move.from == {1, 2}
    assert ai_info.move.to == {1, 3}
  end

  # White to win in one move
  def example1 do
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
    %DemonSpiritGame.Game{
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
    }
  end

  ## Another one where black refuses to move
  def example3 do
    %DemonSpiritGame.Game{
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
    }
  end

  # White Advantage - Best move is {1, 2} to {1, 3}
  # Also forces mate in a few turns, |> AI.alphabeta(6)
  # should have val of 1000000
  def example4 do
    %DemonSpiritGame.Game{
      board: %{
        {1, 2} => %{color: :white, type: :pawn},
        {2, 0} => %{color: :white, type: :king},
        {2, 2} => %{color: :white, type: :pawn},
        {2, 4} => %{color: :black, type: :pawn},
        {3, 2} => %{color: :white, type: :pawn},
        {3, 4} => %{color: :black, type: :king},
        {4, 4} => %{color: :white, type: :pawn}
      },
      cards: %{
        black: [
          %DemonSpiritGame.Card{
            color: :red,
            id: 14,
            moves: [{1, 1}, {1, 0}, {-1, 0}, {-1, -1}],
            name: "Rooster"
          },
          %DemonSpiritGame.Card{
            color: :blue,
            id: 9,
            moves: [{-2, 0}, {-1, 1}, {1, -1}],
            name: "Frog"
          }
        ],
        side: %DemonSpiritGame.Card{
          color: :blue,
          id: 11,
          moves: [{-1, 0}, {0, 1}, {0, -1}],
          name: "Horse"
        },
        white: [
          %DemonSpiritGame.Card{
            color: :red,
            id: 22,
            moves: [{0, 1}, {1, 1}, {-1, -1}],
            name: "Panda"
          },
          %DemonSpiritGame.Card{
            color: :green,
            id: 17,
            moves: [{0, -1}, {-2, 1}, {2, 1}],
            name: "Giraffe"
          }
        ]
      },
      game_name: "lissome-susquehanna-1507",
      turn: :white,
      winner: nil
    }
  end
end
