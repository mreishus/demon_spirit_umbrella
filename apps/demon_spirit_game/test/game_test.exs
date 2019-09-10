defmodule GameTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.Game
  alias DemonSpiritGame.{Game, Card}

  setup do
    # Static list of cards, use when creating a new game to remove RNG from tests
    cards = Card.cards() |> Enum.sort_by(fn card -> card.name end) |> Enum.take(5)
    game = Game.new(cards)
    %{cards: cards, game: game}
  end

  describe "new/0" do
    test "returns a game" do
      game = Game.new()
      # Basic sanity check
      assert game.board
      assert game.board[{0, 0}]
      assert game.board[{4, 4}]
      assert game.board[{4, 4}].color == :black
      assert game.board[{4, 4}].type == :pawn
      assert game.board[{2, 4}].type == :king
      refute game.board[{5, 5}]
      assert game.turn == :white
      refute game.winner

      # Correct number of cards in each list field
      assert length(game.cards.white) == 2
      assert length(game.cards.black) == 2
      assert game.cards.side

      # Verify none of the cards overlap
      assert game.cards.white -- game.cards.black == game.cards.white
      assert game.cards.white -- [game.cards.side] == game.cards.white
      assert game.cards.black -- [game.cards.side] == game.cards.black
    end
  end

  describe "new/1" do
    test "returns a game", %{cards: cards} do
      game = Game.new(cards)
      # Basic sanity check
      assert game.board
      assert game.board[{0, 0}]
      assert game.board[{4, 4}]
      assert game.board[{4, 4}].color == :black
      assert game.board[{4, 4}].type == :pawn
      assert game.board[{2, 4}].type == :king
      refute game.board[{5, 5}]
      assert game.turn == :white
      refute game.winner

      # Correct number of cards in each list field
      assert length(game.cards.white) == 2
      assert length(game.cards.black) == 2
      assert game.cards.side

      # Verify it used the cards we passed in
      assert game.cards.white -- cards == []
      assert game.cards.black -- cards == []
      assert [game.cards.side] -- cards == []

      # Verify none of the cards overlap
      assert game.cards.white -- game.cards.black == game.cards.white
      assert game.cards.white -- [game.cards.side] == game.cards.white
      assert game.cards.black -- [game.cards.side] == game.cards.black
    end
  end

  describe "valid_move_piece_exists/2" do
    test "valid pieces return true", %{game: game} do
      assert game |> Game.valid_move_piece_exists({0, 0})
    end

    test "pieces not on board return false", %{game: game} do
      refute game |> Game.valid_move_piece_exists({2, 2})
    end

    test "pieces belonging to other player return false", %{game: game} do
      refute game |> Game.valid_move_piece_exists({4, 4})
    end
  end

  describe "change_player/1" do
    test "changing player on a new game sets it to black", %{game: game} do
      game = game |> Game.change_player()
      assert game.turn == :black
    end

    test "changing player on a new game twice sets it to white", %{game: game} do
      game = game |> Game.change_player() |> Game.change_player()
      assert game.turn == :white
    end

    test "changing player on a won game does not do anything", %{game: game} do
      game = %{game | turn: :black, winner: :black} |> Game.change_player()
      assert game.turn == :black
    end
  end
end
