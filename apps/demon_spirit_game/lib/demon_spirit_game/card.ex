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
  defstruct id: nil, name: nil, oname: nil, moves: [], color: nil

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
    base_cards() ++ sensei_cards()
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
        oname: "Tiger",
        moves: [{0, 2}, {0, -1}],
        color: :green
      },
      %Card{
        id: 2,
        name: "Crustacean",
        oname: "Crab",
        moves: [{0, 1}, {-2, 0}, {2, 0}],
        color: :green
      },
      %Card{
        id: 3,
        name: "Wukong",
        oname: "Monkey",
        moves: [{-1, 1}, {1, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 4,
        name: "Heron",
        oname: "Crane",
        moves: [{0, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 5,
        name: "Drake",
        oname: "Dragon",
        moves: [{-2, 1}, {2, 1}, {-1, -1}, {1, -1}],
        color: :green
      },
      %Card{
        id: 6,
        name: "Pachyderm",
        oname: "Elephant",
        moves: [{1, 0}, {-1, 0}, {1, 1}, {-1, 1}],
        color: :green
      },
      %Card{
        id: 7,
        name: "Hierodula",
        oname: "Mantis",
        moves: [{-1, 1}, {1, 1}, {0, -1}],
        color: :green
      },
      %Card{
        id: 8,
        name: "Wild Pig",
        oname: "Boar",
        moves: [{0, 1}, {-1, 0}, {1, 0}],
        color: :green
      },
      %Card{
        id: 9,
        name: "Toad",
        oname: "Frog",
        moves: [{-2, 0}, {-1, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 10,
        name: "Chen",
        oname: "Goose",
        moves: [{-1, 1}, {-1, 0}, {1, 0}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 11,
        name: "Pony",
        oname: "Horse",
        moves: [{-1, 0}, {0, 1}, {0, -1}],
        color: :blue
      },
      %Card{
        id: 12,
        name: "Moray",
        oname: "Eel",
        moves: [{-1, 1}, {-1, -1}, {1, 0}],
        color: :blue
      },
      %Card{
        id: 13,
        name: "Hare",
        oname: "Rabbit",
        moves: [{2, 0}, {1, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 14,
        name: "Cockerel",
        oname: "Rooster",
        moves: [{1, 1}, {1, 0}, {-1, 0}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 15,
        name: "Steer",
        oname: "Ox",
        moves: [{1, 0}, {0, 1}, {0, -1}],
        color: :red
      },
      %Card{
        id: 16,
        name: "Python",
        oname: "Cobra",
        moves: [{1, 1}, {1, -1}, {-1, 0}],
        color: :red
      }
    ]
  end

  @spec sensei_cards() :: nonempty_list(%Card{})
  def sensei_cards do
    [
      %Card{
        id: 17,
        name: "Camelopard",
        oname: "Giraffe",
        moves: [{0, -1}, {-2, 1}, {2, 1}],
        color: :green
      },
      %Card{
        id: 18,
        name: "Qilin",
        oname: "Kirin",
        moves: [{1, 2}, {-1, 2}, {0, -2}],
        color: :green
      },
      %Card{
        id: 19,
        name: "Hawk",
        oname: "Phoenix",
        moves: [{-2, 0}, {2, 0}, {-1, 1}, {1, 1}],
        color: :green
      },
      %Card{
        id: 21,
        name: "Vulpa",
        oname: "Fox",
        moves: [{1, 1}, {1, 0}, {1, -1}],
        color: :red
      },
      %Card{
        id: 22,
        name: "Bao Bao",
        oname: "Panda",
        moves: [{0, 1}, {1, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 23,
        name: "Threadsnake",
        oname: "Sea Snake",
        moves: [{0, 1}, {2, 0}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 24,
        name: "Rodent",
        oname: "Mouse",
        moves: [{1, 0}, {0, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 25,
        name: "Raccoon Dog",
        oname: "Tanuki",
        moves: [{0, 1}, {2, 1}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 26,
        name: "Marten",
        oname: "Sable",
        moves: [{1, 1}, {-2, 0}, {-1, -1}],
        color: :red
      },
      %Card{
        id: 27,
        name: "Canine",
        oname: "Dog",
        moves: [{-1, 0}, {-1, 1}, {-1, -1}],
        color: :blue
      },
      %Card{
        id: 28,
        name: "Ursidae",
        oname: "Bear",
        moves: [{0, 1}, {-1, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 29,
        name: "Boa",
        oname: "Viper",
        moves: [{-2, 0}, {0, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 30,
        name: "Bandicoot",
        oname: "Rat",
        moves: [{-1, 0}, {0, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 31,
        name: "Lizard",
        oname: "Iguana",
        moves: [{0, 1}, {-2, 1}, {1, -1}],
        color: :blue
      },
      %Card{
        id: 32,
        name: "Kawauso",
        oname: "Otter",
        moves: [{-1, 1}, {1, -1}, {2, 0}],
        color: :blue
      }
    ]
  end
end
