defmodule GameWinCheckTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.GameWinCheck, import: true
  alias DemonSpiritGame.{Game, Card, GameWinCheck}

  setup do
    # Static list of cards, use when creating a new game to remove RNG from tests
    cards = Card.cards() |> Enum.sort_by(fn card -> card.name end) |> Enum.take(5)
    game = Game.new(cards)

    %{
      game: game
    }
  end

  describe "check/1" do
    test "game with no winner is returned unchanged", %{game: game} do
      new_game = GameWinCheck.check(game)
      assert game == new_game
      assert new_game.winner == nil
    end

    test "white king elimination", %{game: game} do
      {_piece, new_board} = game.board |> Map.pop({2, 0})
      game = %Game{game | board: new_board} |> GameWinCheck.check()
      assert game.winner == :black
    end

    test "black king elimination", %{game: game} do
      {_piece, new_board} = game.board |> Map.pop({2, 4})
      game = %Game{game | board: new_board} |> GameWinCheck.check()
      assert game.winner == :white
    end

    test "white king ascends", %{game: game} do
      # Move Black King to {2, 2}
      {black_king, new_board} = game.board |> Map.pop({2, 4})
      new_board = new_board |> Map.put({2, 2}, black_king)
      game = %Game{game | board: new_board}

      # Move White King to {2, 4}
      {white_king, new_board} = game.board |> Map.pop({2, 0})
      new_board = new_board |> Map.put({2, 4}, white_king)
      game = %Game{game | board: new_board}

      # Check
      game = GameWinCheck.check(game)
      assert game.winner == :white
    end

    test "black king ascends", %{game: game} do
      # Move White King to {2, 2}
      {white_king, new_board} = game.board |> Map.pop({2, 0})
      new_board = new_board |> Map.put({2, 2}, white_king)
      game = %Game{game | board: new_board}

      # Move Black King to {2, 0}
      {black_king, new_board} = game.board |> Map.pop({2, 4})
      new_board = new_board |> Map.put({2, 0}, black_king)
      game = %Game{game | board: new_board}

      # Check
      game = GameWinCheck.check(game)
      assert game.winner == :black
    end
  end
end
