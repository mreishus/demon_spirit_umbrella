defmodule DemonSpiritGame.Card do
  alias DemonSpiritGame.{Card}
  defstruct id: nil, name: nil, moves: [], color: nil

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
