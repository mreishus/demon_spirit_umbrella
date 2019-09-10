defmodule DemonSpiritGame.Card do
  @moduledoc """
  Provides a structure to hold a card containing moves that
  a player may use.  Also contains a hardcoded list of all cards.

  id: Hardcoded integer.
  name: String, name of card.
  moves: List of {int, int} tuples, representing moves.
    {1, 1} is the ability to move the piece up and right one.
  color: Atom, color of the card. Not used in gameplay.
    Blue is left-oriented, red is right-oriented, green is balanced.
  """
  alias DemonSpiritGame.{Card}
  defstruct id: nil, name: nil, moves: [], color: nil

  @doc """
  by_name/1: Retrieve a card by name.
  """
  @spec by_name(String.t()) :: {:ok, %Card{}} | {:error, nil}
  def by_name(name) do
    card = cards() |> Enum.filter(fn c -> c.name == name end)

    case length(card) do
      1 -> {:ok, Enum.at(card, 0)}
      0 -> {:error, nil}
    end
  end

  @doc """
  cards/0:  Provides all 16 cards that may be used in the game.
  A random set of 5 should be chosen when actually playing the game.
  """
  @spec cards() :: nonempty_list(%Card{})
  def cards do
    [
      %Card{
        id: 1,
        name: "Tiger",
        moves: [{0, 2}, {0, -1}],
        color: :green
      },
      %Card{
        id: 2,
        name: "Crab",
        moves: [{0, 1}, {-2, 0}, {2, 0}],
        color: :green
      },
      %Card{
        id: 3,
        name: "Monkey",
        moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 4,
        name: "Crane",
        moves: [{0, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 5,
        name: "Dragon",
        moves: [{-2, 1}, {2, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 6,
        name: "Elephant",
        moves: [{1, 0}, {-1, 0}, {1, 1}, {-1, 1}],
        color: :green
      },
      %Card{
        id: 7,
        name: "Mantis",
        moves: [{-1, 1}, {1, 1}, {0, -1}],
        color: :green
      },
      %Card{
        id: 8,
        name: "Boar",
        moves: [{0, 1}, {-1, 0}, {1, 0}],
        color: :green
      },
      %Card{
        id: 9,
        name: "Frog",
        moves: [{-2, 0}, {-1, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 10,
        name: "Goose",
        moves: [{-1, 1}, {-1, 0}, {1, 0}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 11,
        name: "Horse",
        moves: [{-1, 0}, {0, 1}, {0, -1}],
        color: :blue
      },
      %Card{
        id: 12,
        name: "Eel",
        moves: [{-1, 1}, {-1, -1}, {1, 0}],
        color: :blue
      },
      %Card{
        id: 13,
        name: "Rabbit",
        moves: [{2, 0}, {1, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 14,
        name: "Rooster",
        moves: [{1, 1}, {1, 0}, {-1, 0}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 15,
        name: "Ox",
        moves: [{1, 0}, {0, 1}, {0, -1}],
        color: :red
      },
      %Card{
        id: 16,
        name: "Cobra",
        moves: [{1, 1}, {1, -1}, {-1, 0}],
        color: :red
      }
    ]
  end
end
