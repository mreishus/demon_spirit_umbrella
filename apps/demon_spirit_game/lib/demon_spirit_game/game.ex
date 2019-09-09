defmodule DemonSpiritGame.Game do
  defstruct board: nil
  alias DemonSpiritGame.{Game}

  @doc """
  Create a new game.
  """
  def new do
    %Game{board: initial_board()}
  end

  _ = """
  initial_board: The initial
  setup of the pieces.

          v {4, 4} (top right)
  P P K P P (Black)
  . . . . .
  . . . . .
  . . . . .
  P P K P P (White)
  ^ {0, 0} (bottom left)
  """

  defp initial_board do
    white_pawn = %{type: :pawn, color: :white}
    white_king = %{type: :king, color: :white}
    black_pawn = %{type: :pawn, color: :black}
    black_king = %{type: :king, color: :black}

    %{
      {0, 0} => white_pawn,
      {1, 0} => white_pawn,
      {2, 0} => white_king,
      {3, 0} => white_pawn,
      {4, 0} => white_pawn,
      {0, 4} => black_pawn,
      {1, 4} => black_pawn,
      {2, 4} => black_king,
      {3, 4} => black_pawn,
      {4, 4} => black_pawn
    }
  end
end
