defmodule GameServerTest do
  use ExUnit.Case, async: true

  doctest DemonSpiritGame.GameServer
  alias DemonSpiritGame.{GameServer, Game}

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
    ## Need a way to generate an initial game state w/o RNG
    ## To know a move we can test
  end

  defp generate_game_name do
    "game-#{:rand.uniform(1_000_000)}"
  end
end
