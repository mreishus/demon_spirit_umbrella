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

  @doc """
  start_link/2: Generates a new game server under a provided name.
  Providing :hardcoded_cards removes the RNG of initial card selection
  and simply picks the first 5 cards in alphabetical order.
  This should only be used for testing.
  """
  def start_link(game_name, :hardcoded_cards) do
    GenServer.start_link(__MODULE__, {game_name, :hardcoded_cards}, name: via_tuple(game_name))
  end

  @doc """
  via_tuple/1: Given a game name string, generate a via tuple for addressing the game.
  """
  def via_tuple(game_name), do: {:via, Registry, {DemonSpiritGame.GameRegistry, game_name}}

  @doc """
  game_pid/1: Returns the `pid` of the game server process registered
  under the given `game_name`, or `nil` if no process is registered.
  """
  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

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
  def move(game_name, move = %Move{}) do
    GenServer.call(via_tuple(game_name), {:move, move})
  end

  @doc """
  all_valid_moves/1: Return all valid moves for a game, given its name.
  """
  def all_valid_moves(game_name) do
    GenServer.call(via_tuple(game_name), :all_valid_moves)
  end

  #####################################
  ########### IMPLEMENTATION ##########
  #####################################

  def init({game_name, :hardcoded_cards}) do
    _init(game_name, Game.new(:hardcoded_cards))
  end

  def init({game_name}) do
    _init(game_name, Game.new())
  end

  defp _init(game_name, new_game) do
    game =
      case :ets.lookup(:games, game_name) do
        [] ->
          game = new_game
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

  def handle_call(:all_valid_moves, _from, game) do
    {:reply, Game.all_valid_moves(game), game, @timeout}
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
