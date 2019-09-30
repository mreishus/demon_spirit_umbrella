defmodule CardTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.Card, import: true
  alias DemonSpiritGame.{Card}

  setup do
    drake = %Card{
      id: 5,
      name: "Drake",
      oname: "Dragon",
      moves: [{-2, 1}, {2, 1}, {-1, -1}, {1, -1}],
      color: :green
    }

    hiero = %Card{
      id: 7,
      name: "Hierodula",
      oname: "Mantis",
      moves: [{-1, 1}, {1, 1}, {0, -1}],
      color: :green
    }

    %{drake: drake, hiero: hiero}
  end

  describe "flip/1" do
    test "flips a card", %{drake: drake} do
      flipped_drake = Card.flip(drake)
      assert flipped_drake.moves == [{2, -1}, {-2, -1}, {1, 1}, {-1, 1}]
    end
  end

  describe "by_name/1" do
    test "finds a card by name", %{drake: drake, hiero: hiero} do
      assert Card.by_name("Hierodula") == {:ok, hiero}
      assert Card.by_name("Drake") == {:ok, drake}
    end
  end
end
