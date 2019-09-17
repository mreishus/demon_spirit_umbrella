########## TODO NEEDS TESTS ###############
########## TODO NEEDS TESTS ###############
########## TODO NEEDS TESTS ###############
defmodule DemonSpiritWeb.GameRegistry do
  use GenServer
  require Logger

  defmodule GameInfo do
    defstruct name: nil, created_at: nil
  end

  @topic "game-registry"

  ######### Public API

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def add(game_name) do
    Logger.info("GameRegistry: Asked to add #{game_name}")
    info = %GameInfo{name: game_name, created_at: DateTime.utc_now()}
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
