defmodule DemonSpirit do
  alias DemonSpirit.{Guest, ChatMessage}
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

  def new_chat_message, do: ChatMessage.changeset(%ChatMessage{})

  def fake_insert_chat_message(params) do
    params = params |> Map.put("created", DateTime.utc_now())

    %ChatMessage{}
    |> ChatMessage.changeset(params)
    |> Changeset.apply_action(:insert)
  end
end
