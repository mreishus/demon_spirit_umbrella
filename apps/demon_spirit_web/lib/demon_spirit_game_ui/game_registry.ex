########## TODO NEEDS TESTS ###############
defmodule DemonSpiritWeb.GameRegistry do
  @moduledoc """
    GameRegistry: A centralized list of all games going on, and a little information about them.
    It's stored in key value format, in ETS. 
    keys = game_name (string)
    values = %GameInfo{}, which is a short summary about the game
  """
  use GenServer
  require Logger

  @topic "game-registry"

  ######### Public API

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def add(game_name, info) do
    Logger.info("GameRegistry: Asked to add #{game_name}")
    put(game_name, info)
    notify()
  end

  def update(game_name, info) do
    put(game_name, info)
    notify()
  end

  def remove(game_name) do
    Logger.info("GameRegistry: Asked to remove #{game_name}")
    :ets.delete(__MODULE__, game_name)
    notify()
  end

  def list() do
    :ets.match(__MODULE__, :"$1")
    |> Enum.map(fn [{_k, v}] -> v end)
    |> Enum.sort_by(fn gi -> DateTime.to_iso8601(gi.created_at) end, &>=/2)
  end

  ###### Private Implementation Helpers

  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :public, write_concurrency: true, read_concurrency: true]
    )

    {:ok, nil}
  end

  defp notify() do
    Phoenix.PubSub.broadcast(
      DemonSpiritWeb.PubSub,
      @topic,
      {:state_update, %{}}
    )
  end

  defp put(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end

  defp get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end
end
