########## TODO NEEDS CLEANUP / TESTS ###############
########## TODO NEEDS CLEANUP / TESTS ###############
########## TODO NEEDS CLEANUP / TESTS ###############
########## TODO NEEDS CLEANUP / TESTS ###############
defmodule DemonSpiritWeb.GameRegistry do
  use GenServer

  defmodule GameInfo do
    defstruct name: nil, created_at: nil
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :public, write_concurrency: true, read_concurrency: true]
    )

    {:ok, nil}
  end

  ######### 3

  # Idea:
  # Keep a list of game names, that can be displayed in the lobby
  require Logger

  def add(game_name) do
    Logger.info("GameRegistry: Asked to add #{game_name}")
    info = %GameInfo{name: game_name, created_at: DateTime.utc_now()}
    put(game_name, info)
  end

  def remove(game_name) do
    Logger.info("GameRegistry: Asked to remove #{game_name}")
    :ets.delete(__MODULE__, game_name)
  end

  def list() do
    :ets.match(__MODULE__, :"$1") |> Enum.map(fn [{_k, v}] -> v end)
  end

  ######

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
