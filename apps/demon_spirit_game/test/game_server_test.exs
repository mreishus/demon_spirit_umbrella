defmodule GameServerTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.GameServer
  alias DemonSpiritGame.{GameServer, Game, Move, Card}

  describe "start_link/1" do
    test "spawns a process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameServer.start_link(game_name)
    end

    test "each name can only have one process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameServer.start_link(game_name)
      assert {:error, _reason} = GameServer.start_link(game_name)
    end
  end

  describe "start_link/2" do
    test "spawns a process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameServer.start_link(game_name, :hardcoded_cards)
    end

    test "each name can only have one process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameServer.start_link(game_name, :hardcoded_cards)
      assert {:error, _reason} = GameServer.start_link(game_name, :hardcoded_cards)
    end
  end

  describe "state/1" do
    test "get game state" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameServer.start_link(game_name)
      state = GameServer.state(game_name)
      assert %Game{} = state
      assert state.board |> Map.keys() |> length == 10
    end

    test "get game state (hardcoded cards)" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameServer.start_link(game_name, :hardcoded_cards)
      state = GameServer.state(game_name)
      assert %Game{} = state
      assert state.board |> Map.keys() |> length == 10
      assert state.cards.side.name == "Dragon"
    end
  end

  describe "move/2" do
    setup do
      {:ok, boar} = Card.by_name("Boar")
      {:ok, cobra} = Card.by_name("Cobra")
      {:ok, dragon} = Card.by_name("Dragon")
      %{boar: boar, cobra: cobra, dragon: dragon}
    end

    test "Moving a piece via GameServer", %{cobra: cobra, boar: boar, dragon: dragon} do
      ## Need a way to generate an initial game state w/o RNG
      ## To know a move we can test
      game_name = generate_game_name()
      assert {:ok, _pid} = GameServer.start_link(game_name, :hardcoded_cards)
      game = GameServer.state(game_name)

      ## Simple move
      move = %Move{from: {0, 0}, to: {1, 1}, card: cobra}

      ## Do the move ourself (w/o server)
      {:ok, game_move_manual} = Game.move(game, move)
      {:ok, game_move_server} = GameServer.move(game_name, move)

      ## Are the moves the same?
      assert game_move_manual == game_move_server
      ## Are they diff from the initial state?
      refute game == game_move_server

      ## Did the move do what we expect?
      # Player flipped
      assert game_move_server.turn == :black
      # Card rotated
      assert game_move_server.cards.side == cobra
      assert boar in game_move_server.cards.white
      assert dragon in game_move_server.cards.white
      # Piece Moved
      refute game_move_server.board |> Map.has_key?({0, 0})
      assert game_move_server.board |> Map.has_key?({1, 1})
    end
  end

  describe "all_valid_moves/1" do
    test "a" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameServer.start_link(game_name, :hardcoded_cards)
      moves = GameServer.all_valid_moves(game_name)
      assert length(moves) == 9
      count = moves |> Enum.filter(fn m -> m.from == {4, 0} && m.to == {4, 1} end) |> Enum.count()
      assert count == 1
    end
  end

  describe "active_piece?/2" do
    test "a" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameServer.start_link(game_name, :hardcoded_cards)
      assert GameServer.active_piece?(game_name, {0, 0})
      refute GameServer.active_piece?(game_name, {2, 2})
      refute GameServer.active_piece?(game_name, {4, 4})
    end
  end

  describe "game_summary/1" do
    test "a" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameServer.start_link(game_name, :hardcoded_cards)
      summary = GameServer.game_summary(game_name)
      assert %{game: state, all_valid_moves: moves} = summary
      # Check moves
      assert length(moves) == 9
      count = moves |> Enum.filter(fn m -> m.from == {4, 0} && m.to == {4, 1} end) |> Enum.count()
      assert count == 1
      # Check game
      assert state.board |> Map.keys() |> length == 10
      assert state.cards.side.name == "Dragon"
    end
  end

  defp generate_game_name do
    "game-#{:rand.uniform(1_000_000)}"
  end
end
