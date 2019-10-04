defmodule DemonSpirit.ChatMessage do
  @moduledoc """
  Chat message.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field(:name, :string)
    field(:message, :string)
    field(:created, :utc_datetime)
    # timestamps(type: :utc_datetime) # I can't seem to get these to work w/o a database
  end

  def changeset(base, params \\ %{}) do
    base
    |> cast(params, [:name, :message, :created])
    |> validate_required([:name, :message, :created])
  end
end
