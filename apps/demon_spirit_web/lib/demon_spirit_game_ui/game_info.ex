defmodule DemonSpiritWeb.GameInfo do
  @moduledoc """
  GameInfo holds an abbreviated version of a game in progress.  It's what's everyone
  sees a list of in the lobby.  We periodically update our GameInfo struct in the GameRegistry
  so others in the lobby can see the state of this game (did someone sit down, etc.)
  """
  defstruct name: nil, created_at: nil, white: nil, black: nil, winner: nil, status: nil
end
