defmodule GameTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.Game, import: true
  alias DemonSpiritGame.{Game, Card, Move}

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

  describe "move/3" do
  end

  describe "valid_move?/2" do
    setup do
      {:ok, boar} = Card.by_name("Boar")
      {:ok, cobra} = Card.by_name("Cobra")
      %{boar: boar, cobra: cobra}
    end

    # White's cards are:                   #
    # Boar:  [{0, 1}, {-1, 0}, {1, 0}]    #x#    #
    # Cobra: [{1, 1}, {1, -1}, {-1, 0}]        #x
    #                                            #
    # Black's cards are:                    #
    # Crab:  [{0, 1}, {-2, 0}, {2, 0}]    # x #   #
    # Crane: [{0, 1}, {-1, -1}, {1, -1}]          x
    #                                            # #
    test "some valid moves", %{game: game, boar: boar, cobra: cobra} do
      ## White
      assert Game.valid_move?(game, %Move{from: {0, 0}, to: {0, 1}, card: boar})
      assert Game.valid_move?(game, %Move{from: {0, 0}, to: {1, 1}, card: cobra})
      assert Game.valid_move?(game, %Move{from: {2, 0}, to: {2, 1}, card: boar})
      assert Game.valid_move?(game, %Move{from: {2, 0}, to: {3, 1}, card: cobra})

      ## Black
    end

    test "correct move with wrong card disallowed", %{game: game, boar: boar, cobra: cobra} do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {0, 1}, card: cobra})
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {1, 1}, card: boar})

      ## Black
    end

    test "moving off the board disallowed", %{game: game, boar: boar, cobra: cobra} do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {-1, 0}, card: cobra})
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {-1, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {4, 0}, to: {5, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {1, -1}, card: cobra})

      ## Black
    end

    test "moving to allied piece disallowed", %{game: game, boar: boar} do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {1, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {1, 0}, to: {0, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {1, 0}, to: {2, 0}, card: boar})
      ## Black
    end

    test "unactive player moving disallowed", %{game: game} do
      ## White
      ## Black
    end

    test "moving a blank square disallowed", %{game: game, boar: boar} do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 1}, to: {0, 2}, card: boar})
      refute Game.valid_move?(game, %Move{from: {0, 2}, to: {0, 3}, card: boar})
      ## Black
    end
  end

  describe "card_provides_move?/1" do
  end

  describe "active_piece?/2" do
    test "valid pieces return true", %{game: game} do
      assert game |> Game.active_piece?({0, 0})
    end

    test "pieces not on board return false", %{game: game} do
      refute game |> Game.active_piece?({2, 2})
    end

    test "pieces belonging to other player return false", %{game: game} do
      refute game |> Game.active_piece?({4, 4})
    end
  end

  describe "all_valid_moves/1" do
  end

  describe "valid_coord/1" do
  end

  describe "active_piece_coords/1" do
  end

  describe "possible_moves/2" do
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
