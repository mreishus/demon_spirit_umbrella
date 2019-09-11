defmodule GameSupervisorTest do
  use ExUnit.Case, async: true

  alias DemonSpiritGame.{GameSupervisor, GameServer}

  describe "start_game" do
    test "spawns a game server process" do
      game_name = "game-#{:rand.uniform(1000)}"
      assert {:ok, _pid} = GameSupervisor.start_game(game_name)

      via = GameServer.via_tuple(game_name)
      assert GenServer.whereis(via) |> Process.alive?()
    end

    test "returns an error if game is already started" do
      game_name = "game-#{:rand.uniform(1000)}"

      assert {:ok, pid} = GameSupervisor.start_game(game_name)
      assert {:error, {:already_started, ^pid}} = GameSupervisor.start_game(game_name)
    end
  end

  describe "stop_game" do
    test "terminates the process normally" do
      game_name = "game-#{:rand.uniform(1000)}"
      {:ok, _pid} = GameSupervisor.start_game(game_name)
      via = GameServer.via_tuple(game_name)

      assert :ok = GameSupervisor.stop_game(game_name)
      refute GenServer.whereis(via)
    end
  end
end
