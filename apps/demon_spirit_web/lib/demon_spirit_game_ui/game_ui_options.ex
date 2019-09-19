defmodule DemonSpiritWeb.GameUIOptions do
  @moduledoc """
  Represents selected options while creating a game.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "gameuioptions" do
    # Either "computer" or "human"
    field(:vs, :string)
  end

  def changeset(base, params \\ %{}) do
    base
    |> cast(params, [:vs])
    |> validate_required([:vs])
    |> validate_length(:vs, min: 3)
  end
end
