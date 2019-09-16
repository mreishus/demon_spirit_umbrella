defmodule GameUiServerTest do
  use ExUnit.Case, async: true
  doctest DemonSpiritWeb.GameUIServer
  alias DemonSpiritWeb.{GameUIServer}
  alias DemonSpiritWeb.GameUIServer.State
  alias DemonSpiritGame.Game

  describe "start_link/1" do
    test "spawns a process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameUIServer.start_link(game_name)
    end

    test "each name can only have one process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameUIServer.start_link(game_name)
      assert {:error, _reason} = GameUIServer.start_link(game_name)
    end
  end

  describe "start_link/2" do
    test "spawns a process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
    end

    test "each name can only have one process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      assert {:error, _reason} = GameUIServer.start_link(game_name, :hardcoded_cards)
    end
  end

  describe "state/1" do
    test "get game state" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name)
      state = GameUIServer.state(game_name)
      assert %State{} = state
      assert %Game{} = state.game
      assert state.game.board |> Map.keys() |> length == 10
      assert state.all_valid_moves |> length > 0
    end

    test "get game state (hardcoded cards)" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      state = GameUIServer.state(game_name)
      assert %State{} = state
      assert %Game{} = state.game
      assert state.game.board |> Map.keys() |> length == 10
      assert state.all_valid_moves |> length > 0
      assert state.game.cards.side.name == "Dragon"
    end
  end

  describe "click/2" do
    test "Click on empty square does nothing" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      new_state = GameUIServer.click(game_name, {2, 2})
      assert new_state == initial_state
      assert new_state.move_dest == []
    end

    test "Click on opponents piece does nothing" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      new_state = GameUIServer.click(game_name, {4, 4})
      assert new_state == initial_state
      assert new_state.move_dest == []
    end

    test "Click on my piece selects it" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      new_state = GameUIServer.click(game_name, {0, 0})
      assert new_state.selected == {0, 0}
      assert new_state.move_dest == [{0, 1}, {1, 1}]
    end

    test "Click on my piece, then click on invalid move clears selection" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      _new_state = GameUIServer.click(game_name, {0, 0})
      new_state = GameUIServer.click(game_name, {2, 3})
      assert new_state.selected == nil
      assert new_state.move_dest == []
      assert new_state == initial_state
    end

    test "Click on my piece, then click on valid move, moves it" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      _new_state = GameUIServer.click(game_name, {0, 0})
      new_state = GameUIServer.click(game_name, {1, 1})
      assert new_state != initial_state
      assert new_state.game.board[{1, 1}] != nil
      assert new_state.game.board[{2, 2}] == nil
      assert new_state.move_dest == []
    end
  end

  ## Test Selection
  # new_state = GameUIServer.click("asdf", {0, 0})
  # new_state.selected should be {0, 0}

  ## Test Invalid Move Clears Selection
  # newest_state = GameUIServer.click("asdf", {4, 4})
  # new_state.selected should be nil, and state should be same as original (deselected, no moves)

  ## Test Valid Move works
  #

  defp generate_game_name do
    "game-#{:rand.uniform(1_000_000)}"
  end
end
