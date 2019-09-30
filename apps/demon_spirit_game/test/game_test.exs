defmodule GameTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.Game, import: true
  alias DemonSpiritGame.{Game, Card, Move}

  setup do
    # Static list of cards, use when creating a new game to remove RNG from tests
    cards = Card.base_cards() |> Enum.sort_by(fn card -> card.oname end) |> Enum.take(5)
    game = Game.new(cards)
    game_black = %{game | turn: :black}
    {:ok, boar} = Card.by_name("Wild Pig")
    {:ok, python} = Card.by_name("Python")
    {:ok, crustacean} = Card.by_name("Crustacean")
    {:ok, heron} = Card.by_name("Heron")
    {:ok, drake} = Card.by_name("Drake")
    {:ok, panther} = Card.by_name("Panther")

    %{
      cards: cards,
      game: game,
      game_black: game_black,
      boar: boar,
      python: python,
      crustacean: crustacean,
      heron: heron,
      drake: drake,
      panther: panther
    }
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
    test "one valid move", %{game: game, boar: boar, python: python, drake: drake} do
      move = %Move{from: {0, 0}, to: {1, 1}, card: python}
      {:ok, game} = Game.move(game, move)
      # Player flipped
      assert game.turn == :black
      # Card rotated
      assert game.cards.side == python
      assert boar in game.cards.white
      assert drake in game.cards.white
      # Piece Moved
      refute game.board |> Map.has_key?({0, 0})
      assert game.board |> Map.has_key?({1, 1})
    end

    test "an invalid move", %{game: game, boar: boar} do
      move = %Move{from: {0, 0}, to: {2, 2}, card: boar}
      {status, new_game} = Game.move(game, move)
      assert status == :error
      assert new_game == game
    end
  end

  describe "valid_move?/2" do
    # White's cards are:                   #
    # Boar:  [{0, 1}, {-1, 0}, {1, 0}]    #x#    #
    # python: [{1, 1}, {1, -1}, {-1, 0}]        #x
    #                                            #
    # Black's cards are:                    #
    # crustacean:  [{0, 1}, {-2, 0}, {2, 0}]    # x #   #
    # heron: [{0, 1}, {-1, -1}, {1, -1}]          x
    #                                            # #
    test "some valid moves", %{
      game: game,
      game_black: game_black,
      boar: boar,
      python: python,
      crustacean: crustacean,
      heron: heron
    } do
      ## White
      assert Game.valid_move?(game, %Move{from: {0, 0}, to: {0, 1}, card: boar})
      assert Game.valid_move?(game, %Move{from: {0, 0}, to: {1, 1}, card: python})
      assert Game.valid_move?(game, %Move{from: {2, 0}, to: {2, 1}, card: boar})
      assert Game.valid_move?(game, %Move{from: {2, 0}, to: {3, 1}, card: python})

      ## Black
      assert Game.valid_move?(game_black, %Move{from: {0, 4}, to: {0, 3}, card: crustacean})
      assert Game.valid_move?(game_black, %Move{from: {0, 4}, to: {0, 3}, card: heron})
      assert Game.valid_move?(game_black, %Move{from: {2, 4}, to: {2, 3}, card: crustacean})
      assert Game.valid_move?(game_black, %Move{from: {2, 4}, to: {2, 3}, card: heron})
    end

    test "correct move with wrong card disallowed", %{game: game, boar: boar, python: python} do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {0, 1}, card: python})
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {1, 1}, card: boar})

      ## Black
      # No valid tests with crustacean/heron
    end

    test "moving off the board disallowed", %{
      game: game,
      game_black: game_black,
      boar: boar,
      python: python,
      crustacean: crustacean
    } do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {-1, 0}, card: python})
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {-1, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {4, 0}, to: {5, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {1, -1}, card: python})

      ## Black
      refute Game.valid_move?(game_black, %Move{from: {0, 4}, to: {-2, 4}, card: crustacean})
      refute Game.valid_move?(game_black, %Move{from: {4, 4}, to: {6, 4}, card: crustacean})
    end

    test "moving to allied piece disallowed", %{
      game: game,
      game_black: game_black,
      boar: boar,
      crustacean: crustacean
    } do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {1, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {1, 0}, to: {0, 0}, card: boar})
      refute Game.valid_move?(game, %Move{from: {1, 0}, to: {2, 0}, card: boar})
      ## Black
      refute Game.valid_move?(game_black, %Move{from: {0, 4}, to: {2, 4}, card: crustacean})
      refute Game.valid_move?(game_black, %Move{from: {4, 4}, to: {2, 4}, card: crustacean})
    end

    test "unactive player moving disallowed", %{
      game: game,
      game_black: game_black,
      boar: boar,
      python: python,
      crustacean: crustacean,
      heron: heron
    } do
      ## White
      refute Game.valid_move?(game_black, %Move{from: {0, 0}, to: {0, 1}, card: boar})
      refute Game.valid_move?(game_black, %Move{from: {0, 0}, to: {1, 1}, card: python})
      refute Game.valid_move?(game_black, %Move{from: {2, 0}, to: {2, 1}, card: boar})
      refute Game.valid_move?(game_black, %Move{from: {2, 0}, to: {3, 1}, card: python})

      ## Black
      refute Game.valid_move?(game, %Move{from: {0, 4}, to: {0, 3}, card: crustacean})
      refute Game.valid_move?(game, %Move{from: {0, 4}, to: {0, 3}, card: heron})
      refute Game.valid_move?(game, %Move{from: {2, 4}, to: {2, 3}, card: crustacean})
      refute Game.valid_move?(game, %Move{from: {2, 4}, to: {2, 3}, card: heron})
    end

    test "moving a blank square disallowed", %{
      game: game,
      game_black: game_black,
      boar: boar,
      crustacean: crustacean
    } do
      ## White
      refute Game.valid_move?(game, %Move{from: {0, 1}, to: {0, 2}, card: boar})
      refute Game.valid_move?(game, %Move{from: {0, 2}, to: {0, 3}, card: boar})
      ## Black
      refute Game.valid_move?(game_black, %Move{from: {2, 2}, to: {4, 2}, card: crustacean})
    end

    test "correct move with correct card, but card is not in player's possession disallowed", %{
      game: game,
      panther: panther
    } do
      refute Game.valid_move?(game, %Move{from: {0, 0}, to: {0, 2}, card: panther})
    end
  end

  describe "card_provides_move?/2" do
    test "positive case, white", %{drake: drake} do
      move = %Move{from: {2, 2}, to: {4, 3}, card: drake}
      assert Game.card_provides_move?(move, :white)
      refute Game.card_provides_move?(move, :black)
    end

    test "positive case, black", %{drake: drake} do
      move = %Move{from: {2, 2}, to: {4, 1}, card: drake}
      assert Game.card_provides_move?(move, :black)
      refute Game.card_provides_move?(move, :white)
    end

    test "negative case", %{drake: drake} do
      move = %Move{from: {2, 2}, to: {2, 3}, card: drake}
      refute Game.card_provides_move?(move, :black)
      refute Game.card_provides_move?(move, :white)
    end
  end

  describe "active_player_has_card?/2" do
    test "positive case", %{game: game, boar: boar} do
      assert Game.active_player_has_card?(game, boar)
    end

    test "negative case", %{game: game, crustacean: crustacean} do
      refute Game.active_player_has_card?(game, crustacean)
    end
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
    test "5 boar moves, 4 python moves", %{game: game, boar: boar, python: python} do
      count_boar = Game.all_valid_moves(game) |> Enum.filter(fn m -> m.card == boar end) |> length

      count_python =
        Game.all_valid_moves(game) |> Enum.filter(fn m -> m.card == python end) |> length

      assert count_boar == 5
      assert count_python == 4
    end

    test "no crustacean or heron moves", %{game: game, crustacean: crustacean, heron: heron} do
      # These are the other player's cards, they shouldn't count
      count_crustacean =
        Game.all_valid_moves(game) |> Enum.filter(fn m -> m.card == crustacean end) |> length

      count_heron =
        Game.all_valid_moves(game) |> Enum.filter(fn m -> m.card == heron end) |> length

      assert count_crustacean == 0
      assert count_heron == 0
    end
  end

  describe "valid_coord?/1" do
    test "positive case, tuple" do
      assert Game.valid_coord?({0, 0})
      assert Game.valid_coord?({2, 2})
      assert Game.valid_coord?({4, 4})
      assert Game.valid_coord?({4, 0})
      assert Game.valid_coord?({0, 4})
    end

    test "negative case, tuple" do
      refute Game.valid_coord?({0, 5})
      refute Game.valid_coord?({5, 0})
      refute Game.valid_coord?({5, 5})
      refute Game.valid_coord?({-1, 2})
      refute Game.valid_coord?({2, -1})
    end

    test "positive case, move" do
      assert Game.valid_coord?(%Move{from: {0, 0}, to: {4, 4}, card: nil})
      assert Game.valid_coord?(%Move{from: {0, 4}, to: {4, 0}, card: nil})
    end

    test "negative case, move" do
      refute Game.valid_coord?(%Move{from: {0, 0}, to: {5, 5}, card: nil})
      refute Game.valid_coord?(%Move{from: {0, 5}, to: {5, 0}, card: nil})
      refute Game.valid_coord?(%Move{from: {2, 2}, to: {-1, 2}, card: nil})
    end
  end

  describe "active_piece_coords/1" do
    test "basic case", %{game: game} do
      assert game |> Game.active_piece_coords() == [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}]
    end
  end

  describe "possible_moves/3" do
    test "white drake case", %{drake: drake} do
      moves = Game.possible_moves({2, 2}, drake, :white)
      assert %Move{from: {2, 2}, to: {0, 3}, card: drake} in moves
      assert %Move{from: {2, 2}, to: {4, 3}, card: drake} in moves
      assert %Move{from: {2, 2}, to: {3, 1}, card: drake} in moves
      assert %Move{from: {2, 2}, to: {1, 1}, card: drake} in moves
      assert length(moves) == 4
    end

    test "black drake case", %{drake: drake} do
      moves = Game.possible_moves({2, 2}, drake, :black)

      assert %Move{from: {2, 2}, to: {0, 1}, card: drake} in moves
      assert %Move{from: {2, 2}, to: {4, 1}, card: drake} in moves
      assert %Move{from: {2, 2}, to: {3, 3}, card: drake} in moves
      assert %Move{from: {2, 2}, to: {1, 3}, card: drake} in moves
      assert length(moves) == 4
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

# To test in IEX:
# alias DemonSpiritGame.{Game, Card, Move}
# {:ok, python} = Card.by_name("python")
# move = %Move{from: {0, 0}, to: {1, 1}, card: python}
# cards = Card.cards() |> Enum.sort_by(fn card -> card.name end) |> Enum.take(5)
# game = Game.new(cards)
