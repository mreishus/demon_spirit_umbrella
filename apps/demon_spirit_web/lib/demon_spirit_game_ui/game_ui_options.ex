defmodule DemonSpiritWeb.GameUIOptions do
  @moduledoc """
  Represents selected options while creating a game.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "gameuioptions" do
    # Either "computer" or "human"
    field(:vs, :string)
    field(:computer_skill, :integer)
  end

  def changeset(base, params \\ %{}) do
    base
    |> cast(params, [:vs, :computer_skill])
    |> validate_required([:vs])
    |> validate_inclusion(:vs, ~w(human computer))
  end
end
