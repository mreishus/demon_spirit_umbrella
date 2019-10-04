defmodule DemonSpiritWeb.ChatView do
  use DemonSpiritWeb, :view

  @doc """
  date_to_hms/1: Turn a DateTime into a string representing the hour and minute in UTC.
  """
  def date_to_hms(a) do
    DemonSpiritWeb.GameView.date_to_hms(a)
  end
end
