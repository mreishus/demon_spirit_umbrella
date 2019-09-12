defmodule DemonSpirit do
  alias DemonSpirit.{Guest}
  alias Ecto.Changeset

  @moduledoc """
  DemonSpirit keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def new_guest, do: Guest.changeset(%Guest{})

  def fake_insert_guest(params) do
    %Guest{}
    |> Guest.changeset(params)
    |> Changeset.apply_action(:insert)
  end
end
