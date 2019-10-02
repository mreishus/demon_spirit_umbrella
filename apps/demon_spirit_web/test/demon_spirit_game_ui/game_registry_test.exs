defmodule GameRegistryTest do
  use ExUnit.Case, async: true
  alias DemonSpiritWeb.{GameRegistry}
  alias DemonSpiritWeb.GameUIServer.GameInfo

  describe "start_link/1" do
    test "Already started by application" do
      # assert {:error, {:already_started, _pid}} = GameRegistry.start_link(nil)
    end
  end

  describe "add/2" do
    test "Adding works" do
      GameRegistry.start_link(nil)
      game_name = generate_game_name()

      count_before = GameRegistry.list() |> length()
      GameRegistry.add(game_name, %GameInfo{})
      count_after = GameRegistry.list() |> length()
      assert count_before + 1 == count_after
    end
  end

  describe "remove/2" do
    test "Removing works" do
      GameRegistry.start_link(nil)
      game_name = generate_game_name()

      count_before = GameRegistry.list() |> length()

      GameRegistry.add(game_name, %GameInfo{})
      count_after_add = GameRegistry.list() |> length()
      assert count_before + 1 == count_after_add

      GameRegistry.remove(game_name)
      count_after_remove = GameRegistry.list() |> length()
      assert count_after_remove == count_before
    end
  end

  describe "update/2" do
    test "Updating works" do
      GameRegistry.start_link(nil)
      game_name = generate_game_name()
      game_info_1 = %GameInfo{name: game_name, status: :staging}
      game_info_2 = %GameInfo{name: game_name, status: :playing}

      GameRegistry.add(game_name, game_info_1)
      game = GameRegistry.list() |> Enum.filter(fn g -> g.name == game_name end) |> Enum.at(0)
      assert game.status == :staging
      GameRegistry.update(game_name, game_info_2)
      game = GameRegistry.list() |> Enum.filter(fn g -> g.name == game_name end) |> Enum.at(0)
      assert game.status == :playing
    end
  end

  defp generate_game_name do
    "game-#{:rand.uniform(1_000_000)}"
  end
end
