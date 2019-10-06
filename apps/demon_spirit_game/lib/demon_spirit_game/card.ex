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

  Input: A String of the name to search for.
  Output: Either {:ok, card} or {:error, nil}
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
  flip/1: Return a card with all of the moves flipped.
  That is, a {2, 1} will become a {-2, -1}.

  This is needed when black is playing, since by default, all
  moves specified are from white's perspective.

  Input: %Card
  Output: %Card with moves flipped.
  """
  @spec flip(%Card{}) :: %Card{}
  def flip(card) do
    flipped_moves = card.moves |> Enum.map(fn {x, y} -> {-x, -y} end)
    %{card | moves: flipped_moves}
  end

  @spec cards() :: nonempty_list(%Card{})
  def cards do
    base_cards() ++ exp1_cards() ++ exp2_cards()
  end

  @doc """
  cards/0:  Provides all 16 cards that may be used in the game.
  A random set of 5 should be chosen when actually playing the game.
  """
  @spec base_cards() :: nonempty_list(%Card{})
  def base_cards do
    [
      %Card{
        id: 1,
        name: "Panther",
        moves: [{0, 2}, {0, -1}],
        color: :green
      },
      %Card{
        id: 2,
        name: "Crustacean",
        moves: [{0, 1}, {-2, 0}, {2, 0}],
        color: :green
      },
      %Card{
        id: 3,
        name: "Wukong",
        moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 4,
        name: "Heron",
        moves: [{0, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 5,
        name: "Drake",
        moves: [{-2, 1}, {2, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 6,
        name: "Pachyderm",
        moves: [{1, 0}, {-1, 0}, {1, 1}, {-1, 1}],
        color: :green
      },
      %Card{
        id: 7,
        name: "Hierodula",
        moves: [{-1, 1}, {1, 1}, {0, -1}],
        color: :green
      },
      %Card{
        id: 8,
        name: "Wild Pig",
        moves: [{0, 1}, {-1, 0}, {1, 0}],
        color: :green
      },
      %Card{
        id: 9,
        name: "Toad",
        moves: [{-2, 0}, {-1, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 10,
        name: "Chen",
        moves: [{-1, 1}, {-1, 0}, {1, 0}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 11,
        name: "Pony",
        moves: [{-1, 0}, {0, 1}, {0, -1}],
        color: :blue
      },
      %Card{
        id: 12,
        name: "Moray",
        moves: [{-1, 1}, {-1, -1}, {1, 0}],
        color: :blue
      },
      %Card{
        id: 13,
        name: "Hare",
        moves: [{2, 0}, {1, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 14,
        name: "Cockerel",
        moves: [{1, 1}, {1, 0}, {-1, 0}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 15,
        name: "Steer",
        moves: [{1, 0}, {0, 1}, {0, -1}],
        color: :red
      },
      %Card{
        id: 16,
        name: "Python",
        moves: [{1, 1}, {1, -1}, {-1, 0}],
        color: :red
      }
    ]
  end

  @spec exp1_cards() :: nonempty_list(%Card{})
  def exp1_cards do
    [
      %Card{
        id: 17,
        name: "Camelopard",
        moves: [{0, -1}, {-2, 1}, {2, 1}],
        color: :green
      },
      %Card{
        id: 18,
        name: "Qilin",
        moves: [{1, 2}, {-1, 2}, {0, -2}],
        color: :green
      },
      %Card{
        id: 19,
        name: "Hawk",
        moves: [{-2, 0}, {2, 0}, {-1, 1}, {1, 1}],
        color: :green
      },
      # %Card{
      #   id: 21,
      #   name: "Vulpa",
      #   moves: [{1, 1}, {1, 0}, {1, -1}],
      #   color: :red
      # },
      %Card{
        id: 22,
        name: "Bao Bao",
        moves: [{0, 1}, {1, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 23,
        name: "Threadsnake",
        moves: [{0, 1}, {2, 0}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 24,
        name: "Rodent",
        moves: [{1, 0}, {0, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 25,
        name: "Raccoon Dog",
        moves: [{0, 1}, {2, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 26,
        name: "Marten",
        moves: [{1, 1}, {-2, 0}, {-1, -1}],
        color: :red
      },
      # %Card{
      #   id: 27,
      #   name: "Canine",
      #   moves: [{-1, 0}, {-1, 1}, {-1, -1}],
      #   color: :blue
      # },
      %Card{
        id: 28,
        name: "Ursidae",
        moves: [{0, 1}, {-1, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 29,
        name: "Boa",
        moves: [{-2, 0}, {0, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 30,
        name: "Bandicoot",
        moves: [{-1, 0}, {0, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 31,
        name: "Lizard",
        moves: [{0, 1}, {-2, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 32,
        name: "Kawauso",
        moves: [{-1, 1}, {1, -1}, {2, 0}],
        color: :blue
      }
    ]
  end

  @spec exp2_cards() :: nonempty_list(%Card{})
  def exp2_cards do
    # Green - Default
    # Blue - Left
    # Red - Right
    [
      %Card{
        id: 33,
        name: "Wasp",
        moves: [{-1, 1}, {-1, -1}, {1, 2}, {1, -2}],
        color: :red
      },
      %Card{
        id: 34,
        name: "Bee",
        moves: [{1, 1}, {1, -1}, {-1, 2}, {-1, -2}],
        color: :blue
      },
      # %Card{
      #   id: 35,
      #   name: "Mole",
      #   moves: [{2, 0}, {2, -1}, {2, 1}],
      #   color: :red
      # },
      # %Card{
      #   id: 36,
      #   name: "Gopher",
      #   moves: [{-2, 0}, {-2, -1}, {-2, 1}],
      #   color: :blue
      # },
      %Card{
        id: 37,
        name: "Duck",
        moves: [{0, 1}, {1, 0}, {2, 2}],
        color: :red
      },
      %Card{
        id: 38,
        name: "Swan",
        moves: [{0, 1}, {-1, 0}, {-2, 2}],
        color: :blue
      },
      %Card{
        id: 39,
        name: "Raging Demon",
        moves: [{0, 2}, {1, 1}, {-1, 1}],
        color: :green
      },
      %Card{
        id: 40,
        name: "Dolphin",
        moves: [{0, 1}, {-1, 0}, {1, 2}],
        color: :red
      },
      %Card{
        id: 41,
        name: "Shark",
        moves: [{0, 1}, {1, 0}, {-1, 2}],
        color: :blue
      },
      %Card{
        id: 42,
        name: "Eagle",
        moves: [{2, 2}, {-2, 2}, {0, -1}],
        color: :green
      },
      %Card{
        id: 43,
        name: "Piglet",
        moves: [{0, 1}, {-1, 0}, {1, 0}],
        color: :green
      },
      %Card{
        id: 44,
        name: "Warthog",
        moves: [{0, 1}, {0, -1}, {-1, 0}, {1, 0}],
        color: :green
      }
    ]
  end
end
