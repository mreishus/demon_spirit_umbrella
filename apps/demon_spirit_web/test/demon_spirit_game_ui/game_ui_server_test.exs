defmodule GameUiServerTest do
  use ExUnit.Case, async: true
  doctest DemonSpiritWeb.GameUIServer
  alias DemonSpiritWeb.{GameUIServer, GameUI, GameUIOptions}
  alias DemonSpiritGame.{Game, Move}

  defp default_options do
    %GameUIOptions{
      vs: "human"
    }
  end

  describe "start_link/2, default" do
    test "spawns a process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameUIServer.start_link(game_name, default_options())
    end

    test "each name can only have one process" do
      game_name = generate_game_name()

      assert {:ok, _pid} = GameUIServer.start_link(game_name, default_options())
      assert {:error, _reason} = GameUIServer.start_link(game_name, default_options())
    end
  end

  describe "start_link/2, hardcoded_cards" do
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
      assert {:ok, _pid} = GameUIServer.start_link(game_name, default_options())
      state = GameUIServer.state(game_name)
      assert %GameUI{} = state
      assert %Game{} = state.game
      assert state.game.board |> Map.keys() |> length == 10
      assert state.all_valid_moves |> length > 0
    end

    test "get game state (hardcoded cards)" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      state = GameUIServer.state(game_name)
      assert %GameUI{} = state
      assert %Game{} = state.game
      assert state.game.board |> Map.keys() |> length == 10
      assert state.all_valid_moves |> length > 0
      assert state.game.cards.side.name == "Drake"
    end
  end

  describe "click/3" do
    test "Click on empty square does nothing" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      new_state = GameUIServer.click(game_name, {2, 2}, :test)
      assert new_state == initial_state
      assert new_state.move_dest == []
      assert new_state.last_move == nil
    end

    test "Click on opponents piece does nothing" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      new_state = GameUIServer.click(game_name, {4, 4}, :test)
      assert new_state == initial_state
      assert new_state.move_dest == []
      assert new_state.last_move == nil
    end

    test "Click on my piece selects it" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      new_state = GameUIServer.click(game_name, {0, 0}, :test)
      assert new_state.selected == {0, 0}
      assert new_state.move_dest == [{0, 1}, {1, 1}]
      assert new_state.last_move == nil
    end

    test "Click on my piece, then click on invalid move clears selection" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      _new_state = GameUIServer.click(game_name, {0, 0}, :test)
      new_state = GameUIServer.click(game_name, {2, 3}, :test)
      assert new_state.selected == nil
      assert new_state.move_dest == []
      assert new_state == initial_state
      assert new_state.last_move == nil
    end

    test "Click on my piece, then click on valid move, moves it" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      initial_state = GameUIServer.state(game_name)
      _new_state = GameUIServer.click(game_name, {0, 0}, :test)
      new_state = GameUIServer.click(game_name, {1, 1}, :test)
      assert new_state != initial_state
      assert new_state.game.board[{1, 1}] != nil
      assert new_state.game.board[{2, 2}] == nil
      assert new_state.move_dest == []
      assert %Move{} = new_state.last_move
      assert new_state.last_move.from == {0, 0}
      assert new_state.last_move.to == {1, 1}
    end
  end

  describe "sit_down_if_possible/2" do
    test "First sit goes to white" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      state = GameUIServer.sit_down_if_possible(game_name, :p1)
      assert state.white == :p1
    end

    test "Second sit goes to black" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      GameUIServer.sit_down_if_possible(game_name, :p1)
      state = GameUIServer.sit_down_if_possible(game_name, :p2)
      assert state.white == :p1
      assert state.black == :p2
    end

    test "Third sit goes to neither" do
      game_name = new_game_with_p1_p2_sitting()
      state = GameUIServer.sit_down_if_possible(game_name, :p3)
      assert state.white == :p1
      assert state.black == :p2
    end

    test "Can't sit in white and black at same time" do
      game_name = generate_game_name()
      assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
      GameUIServer.sit_down_if_possible(game_name, :p1)
      GameUIServer.sit_down_if_possible(game_name, :p1)
      state = GameUIServer.sit_down_if_possible(game_name, :p1)
      assert state.white == :p1
      assert state.black == nil
    end
  end

  describe "only current sitting player allowed to click" do
    test "correct player clicks, state changes" do
      game_name = new_game_with_p1_p2_sitting()

      new_state = GameUIServer.click(game_name, {0, 0}, :p1)
      assert new_state.selected == {0, 0}
      assert new_state.move_dest == [{0, 1}, {1, 1}]
      assert new_state.last_move == nil
    end

    test "incorrect player clicks, state is unchanged" do
      game_name = new_game_with_p1_p2_sitting()
      state = GameUIServer.state(game_name)

      new_state = GameUIServer.click(game_name, {0, 0}, :p2)
      assert state == new_state
      refute new_state.selected == {0, 0}
      refute new_state.move_dest == [{0, 1}, {1, 1}]
    end
  end

  describe "clarification system" do
    test "clarification state invoked" do
      game_name = game_in_clarification_state()
      state = GameUIServer.state(game_name)
      assert length(state.moves_need_clarify) == 2
      assert state.game.turn == :black
    end

    test "correct clarification (choose card 0)" do
      game_name = game_in_clarification_state()
      GameUIServer.clarify_move(game_name, 0, :p2)
      state = GameUIServer.state(game_name)
      assert state.moves_need_clarify == nil
      assert state.game.turn == :white
      assert state.game.cards.side.name == "Crustacean"
    end

    test "correct clarification (choose card 1)" do
      game_name = game_in_clarification_state()
      GameUIServer.clarify_move(game_name, 1, :p2)
      state = GameUIServer.state(game_name)
      assert state.moves_need_clarify == nil
      assert state.game.turn == :white
      assert state.game.cards.side.name == "Heron"
    end

    test "correct clarification (cancel)" do
      game_name = game_in_clarification_state()
      GameUIServer.clarify_cancel(game_name, :p2)
      state = GameUIServer.state(game_name)
      assert state.moves_need_clarify == nil
      assert state.game.turn == :black
    end

    test "opponent can't clarify" do
      game_name = game_in_clarification_state()
      GameUIServer.clarify_move(game_name, 0, :p1)
      state = GameUIServer.state(game_name)
      assert length(state.moves_need_clarify) == 2
      assert state.game.turn == :black
    end

    test "opponent can't cancel clarify" do
      game_name = game_in_clarification_state()
      GameUIServer.clarify_cancel(game_name, :p1)
      state = GameUIServer.state(game_name)
      assert length(state.moves_need_clarify) == 2
      assert state.game.turn == :black
    end
  end

  describe "drag and drop system" do
    test "start drag sets selected state" do
      game_name = new_game_with_p1_p2_sitting()
      state1 = GameUIServer.state(game_name)
      GameUIServer.drag_start(game_name, {1, 0}, :p1)
      state2 = GameUIServer.state(game_name)
      assert state1 != state2
      assert state2.selected == {1, 0}
    end

    test "complete drag and drop moves piece" do
      game_name = new_game_with_p1_p2_sitting()
      state1 = GameUIServer.state(game_name)
      GameUIServer.drag_start(game_name, {1, 0}, :p1)
      GameUIServer.drag_drop(game_name, {1, 0}, {1, 1}, :p1)
      state2 = GameUIServer.state(game_name)
      assert state1 != state2
      assert state2.game.board[{1, 1}] != nil
    end

    test "opponent isn't allowed to drag and drop" do
      game_name = new_game_with_p1_p2_sitting()
      state1 = GameUIServer.state(game_name)
      GameUIServer.drag_start(game_name, {1, 0}, :p2)
      GameUIServer.drag_drop(game_name, {1, 0}, {1, 1}, :p2)
      state2 = GameUIServer.state(game_name)
      assert state1 == state2
    end

    test "start drag, then cancel restores original state" do
      game_name = new_game_with_p1_p2_sitting()
      state1 = GameUIServer.state(game_name)
      GameUIServer.drag_start(game_name, {1, 0}, :p1)
      GameUIServer.drag_end(game_name, :p1)
      state2 = GameUIServer.state(game_name)
      assert state1 == state2
    end
  end

  defp game_in_clarification_state do
    game_name = new_game_with_p1_p2_sitting()
    # White moves up one
    GameUIServer.click(game_name, {1, 0}, :test)
    GameUIServer.click(game_name, {1, 1}, :test)
    # Black attempts to move up one, but two moves possible
    # Crustacean(0) / Heron(1)
    GameUIServer.click(game_name, {2, 4}, :test)
    GameUIServer.click(game_name, {2, 3}, :test)
    game_name
  end

  defp new_game_with_p1_p2_sitting do
    game_name = generate_game_name()
    assert {:ok, _pid} = GameUIServer.start_link(game_name, :hardcoded_cards)
    GameUIServer.sit_down_if_possible(game_name, :p1)
    GameUIServer.sit_down_if_possible(game_name, :p2)
    game_name
  end

  defp generate_game_name do
    "game-#{:rand.uniform(1_000_000)}"
  end
end
