defmodule DemonSpiritWeb.GameView do
  use DemonSpiritWeb, :view
  alias DemonSpiritWeb.GameUI

  @doc """
  staging?/1: Given the current gameui, is it in a staging state?
  The staging state is when we are waiting for players to sit down
  and ready up before the game begins.
  """
  def staging?(gameui) do
    GameUI.staging?(gameui)
  end

  @doc """
  show_ready_button?/1: Given a gameui state and a player, should
  they see the ready button?
  """
  def show_ready_button?(gameui, guest) do
    cond do
      staging?(gameui) and gameui.black == guest and not gameui.black_ready ->
        true

      staging?(gameui) and gameui.white == guest and not gameui.white_ready ->
        true

      true ->
        false
    end
  end

  @doc """
  show_ready_button?/1: Given a gameui state and a player, should
  they see the "not ready" button?
  """
  def show_not_ready_button?(gameui, guest) do
    cond do
      staging?(gameui) and gameui.black == guest and gameui.black_ready ->
        true

      staging?(gameui) and gameui.white == guest and gameui.white_ready ->
        true

      true ->
        false
    end
  end

  @doc """
  date_to_md/1: Turn a DateTime into a string representing the month and day in UTC.
  """
  def date_to_md(a) do
    "#{a.month}/#{a.day}"
  end

  @doc """
  date_to_hms/1: Turn a DateTime into a string representing the hour and minute in UTC.
  """
  def date_to_hms(a) do
    "#{a.hour}:#{zero_pad(a.minute)}"
  end

  # Zero_pad: Given an integer and an amount, pad left with 0s. 
  # Returns string. zero_pad(1, 2) = "01". zero_pad(1, 3) = "001".
  @spec zero_pad(Integer, Integer) :: String
  defp zero_pad(number, amount \\ 2) do
    number
    |> Integer.to_string()
    |> String.rjust(amount, ?0)
  end
end
