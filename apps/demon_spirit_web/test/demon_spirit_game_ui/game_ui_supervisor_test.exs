defmodule GameUiSupervisorTest do
  use ExUnit.Case, async: true
  doctest DemonSpiritWeb.GameUISupervisor

  alias DemonSpiritWeb.{GameUISupervisor, GameUIServer}

  describe "start_game" do
    test "spawns a game server process" do
      game_name = "game-#{:rand.uniform(1000)}"
      assert {:ok, _pid} = GameUISupervisor.start_game(game_name)

      via = GameUIServer.via_tuple(game_name)
      assert GenServer.whereis(via) |> Process.alive?()
    end

    test "returns an error if game is already started" do
      game_name = "game-#{:rand.uniform(1000)}"

      assert {:ok, pid} = GameUISupervisor.start_game(game_name)
      assert {:error, {:already_started, ^pid}} = GameUISupervisor.start_game(game_name)
    end
  end

  describe "stop_game" do
    test "terminates the process normally" do
      game_name = "game-#{:rand.uniform(1000)}"
      {:ok, _pid} = GameUISupervisor.start_game(game_name)
      via = GameUIServer.via_tuple(game_name)

      assert :ok = GameUISupervisor.stop_game(game_name)
      refute GenServer.whereis(via)
    end
  end

  # describe "ets preservation of crashed processes" do
  #  test "supervised game gets restarted and retains status after crashing" do
  #
  # .... GameUISupervisor / GameUIServer does not currently do this .....
  #
  #  end
  # end
end
