defmodule GameUiTest do
  use ExUnit.Case, async: true
  alias DemonSpiritWeb.{GameUI, GameUIOptions}

  describe "clarify_cancel/2" do
    test "current player allowed to cancel clarification" do
      game_name = generate_game_name()
      g = GameUI.new(game_name, %GameUIOptions{vs: "human"})

      g =
        %{
          g
          | white: :p1,
            black: :p2,
            selected: :selected_junk,
            move_dest: :move_dest_junk,
            moves_need_clarify: :moves_need_clarify_junk
        }
        |> GameUI.clarify_cancel(:p1)

      assert g.moves_need_clarify == nil
      assert g.selected == nil
      assert g.move_dest == []
    end

    test "opponent not allowed to cancel clarification" do
      game_name = generate_game_name()
      g = GameUI.new(game_name, %GameUIOptions{vs: "human"})

      g = %{
        g
        | white: :p1,
          black: :p2,
          selected: :selected_junk,
          move_dest: :move_dest_junk,
          moves_need_clarify: :moves_need_clarify_junk
      }

      g_new = g |> GameUI.clarify_cancel(:p2)

      assert g == g_new
    end
  end

  defp generate_game_name do
    "game-#{:rand.uniform(1_000_000)}"
  end
end
