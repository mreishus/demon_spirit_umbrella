defmodule DemonSpiritWeb.GameView do
  use DemonSpiritWeb, :view

  def date_to_md(a) do
    "#{a.month}/#{a.day}"
  end

  def date_to_hms(a) do
    "#{a.hour}:#{zero_pad(a.minute)}"
  end

  @spec zero_pad(Integer, Integer) :: String
  defp zero_pad(number, amount \\ 2) do
    number
    |> Integer.to_string()
    |> String.rjust(amount, ?0)
  end
end
