defmodule DemonSpirit.Guest do
  @moduledoc """
  Guest represents a low-friction, ephemeral login.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "guests" do
    field(:name, :string)
  end

  def changeset(base, params \\ %{}) do
    base
    |> cast(params, [:name, :id])
    |> validate_required([:name, :id])
    |> validate_length(:name, min: 3)
  end

  # Do I need an ID to prevent Name conflicts?
  # @primary_key {:id, :binary_id, autogenerate: false}
  # %DemonSpirit.Guest{name: name, id: Ecto.UUID.generate()}
end
