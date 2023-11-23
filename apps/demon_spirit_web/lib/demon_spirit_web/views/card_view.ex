defmodule DemonSpiritWeb.CardView do
  use DemonSpiritWeb, :view

  def outer_card_class(card_class, card_color) do
    "card #{card_class} bg-gray-200 border shadow-md rounded inline-block w-20 md:w-24 lg:w-32 #{card_color} text-sm"
  end

  def inner_card_class(flip) do
    base_class = "p-2 pt-0"
    flip_class = if flip, do: " flip", else: ""

    "#{base_class}#{flip_class}"
  end

  def span_class(card_name) do
    base_class = "title font-semibold py-1 inline-block"
    size_class = if String.length(card_name) > 8, do: " text-md", else: " text-lg"

    "#{base_class}#{size_class}"
  end

  def cell_class(x, y, card_moves) do
    base_class = "card_cell border border-black w-1/5 p-0"
    move_class = if {x, y} in card_moves, do: " move", else: ""
    center_class = if {x, y} == {0, 0}, do: " center", else: ""

    "#{base_class}#{move_class}#{center_class}"
  end
end
