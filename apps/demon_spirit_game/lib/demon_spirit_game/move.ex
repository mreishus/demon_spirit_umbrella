defmodule DemonSpiritGame.Move do
  @moduledoc """
  Represents a move.
  from: {x, y} tuple of two ints: Destination coords
  to: {x, y} tuple of two ints: Destination coords
  card: Card being used to make the move
  """
  defstruct from: {}, to: {}, card: nil
end
