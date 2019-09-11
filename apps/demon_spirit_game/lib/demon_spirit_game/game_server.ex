defmodule DemonSpiritGame.GameServer do
  @moduledoc """
  Genserver to hold a %Game{}'s state within a process.
  """
  use GenServer
  @timeout :timer.hours(2)

  alias DemonSpiritGame.{Game, Move}

  #####################################
  ########### PUBLIC API ##############
  #####################################

  @doc """
  start_link/1: Generates a new game server under a provided name.
  """
  # Using type specs in genserver causes my app to not compile..??
  # @spec start_link(t.String) :: {:ok, pid} | {:error, any}
  def start_link(game_name) do
    GenServer.start_link(__MODULE__, {game_name}, name: via_tuple(game_name))
  end

  def via_tuple(game_name), do: {:via, Registry, {DemonSpiritGame.GameRegistry, game_name}}

  @doc """
  state/1:  Retrieves the game state for the game under a provided name.
  """
  # @spec state(t.String) :: %Game{}
  def state(game_name) do
    GenServer.call(via_tuple(game_name), :state)
  end

  @doc """
  move/2: Applies the given move to a game and returns the new game state.
  """
  # @spec move(t.String, %Move{}) :: {:ok, %Game{}} | {:error, :invalid_move}
  def(move(game_name, move = %Move{})) do
    GenServer.call(via_tuple(game_name), {:move, move})
  end

  #####################################
  ########### IMPLEMENTATION ##########
  #####################################

  def init({game_name}) do
    game =
      case :ets.lookup(:games, game_name) do
        [] ->
          game = Game.new()
          :ets.insert(:games, {game_name, game})
          game

        [{^game_name, game}] ->
          game
      end

    {:ok, game, @timeout}
  end

  def handle_call(:state, _from, game) do
    {:reply, game, game, @timeout}
  end

  def handle_call({:move, move = %Move{}}, _from, game) do
    case Game.move(game, move) do
      {:ok, new_game} ->
        :ets.insert(:games, {my_game_name(), new_game})
        {:reply, {:ok, new_game}, new_game, @timeout}

      {:error, _} ->
        # ???
        {:reply, {:error, :invalid_move}, game, @timeout}
    end
  end

  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  def terminate({:shutdown, :timeout}, _game) do
    :ets.delete(:games, my_game_name())
    :ok
  end

  def terminate(_reason, _game) do
    :ok
  end

  defp my_game_name do
    Registry.keys(DemonSpiritGame.GameRegistry, self()) |> List.first()
  end
end
