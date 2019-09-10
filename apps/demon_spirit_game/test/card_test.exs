defmodule CardTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.Card, import: true
  alias DemonSpiritGame.{Game, Card, Move}

  setup do
    dragon = %Card{
      id: 5,
      name: "Dragon",
      moves: [{-2, 1}, {2, 1}, {-1, -1}, {1, -1}],
      color: :green
    }

    mantis = %Card{
      id: 7,
      name: "Mantis",
      moves: [{-1, 1}, {1, 1}, {0, -1}],
      color: :green
    }

    %{dragon: dragon, mantis: mantis}
  end

  describe "flip/1" do
    test "flips a card", %{dragon: dragon} do
      flipped_dragon = Card.flip(dragon)
      assert flipped_dragon.moves == [{2, -1}, {-2, -1}, {1, 1}, {-1, 1}]
    end
  end

  describe "by_name/1" do
    test "finds a card by name", %{dragon: dragon, mantis: mantis} do
      cards = [dragon, mantis]
      assert Card.by_name("Mantis") == {:ok, mantis}
      assert Card.by_name("Dragon") == {:ok, dragon}
    end
  end
end
