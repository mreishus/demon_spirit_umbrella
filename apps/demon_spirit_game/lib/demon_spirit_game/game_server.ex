defmodule DemonSpiritGame.GameServer do
  @moduledoc """
  Genserver to hold a %Game{}'s state within a process.
  """
  use GenServer
  require Logger
  @timeout :timer.hours(1)

  alias DemonSpiritGame.{Game, Move}

  #####################################
  ########### PUBLIC API ##############
  #####################################

  @doc """
  start_link/1: Generates a new game server under a provided name.
  """
  @spec start_link(String.t()) :: {:ok, pid} | {:error, any}
  def start_link(game_name) do
    GenServer.start_link(__MODULE__, {game_name}, name: via_tuple(game_name))
  end

  @doc """
  start_link/2: Generates a new game server under a provided name.
  Providing :hardcoded_cards removes the RNG of initial card selection
  and simply picks the first 5 cards in alphabetical order.
  This should only be used for testing.
  """
  @spec start_link(String.t(), :hardcoded_cards) :: {:ok, pid} | {:error, any}
  def start_link(game_name, :hardcoded_cards) do
    GenServer.start_link(__MODULE__, {game_name, :hardcoded_cards}, name: via_tuple(game_name))
  end

  @doc """
  via_tuple/1: Given a game name string, generate a via tuple for addressing the game.
  """
  def via_tuple(game_name),
    do: {:via, Registry, {DemonSpiritGame.GameRegistry, {__MODULE__, game_name}}}

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
  @spec state(String.t()) :: %Game{} | nil
  def state(game_name) do
    case game_pid(game_name) do
      nil -> nil
      _ -> GenServer.call(via_tuple(game_name), :state)
    end
  end

  @doc """
  move/2: Applies the given move to a game and returns the new game state.
  """
  @spec move(String.t(), %Move{}) :: {:ok, %Game{}} | {:error, :invalid_move}
  def move(game_name, move = %Move{}) do
    GenServer.call(via_tuple(game_name), {:move, move})
  end

  @doc """
  all_valid_moves/1: Return all valid moves for a game, given its name.
  """
  def all_valid_moves(game_name) do
    GenServer.call(via_tuple(game_name), :all_valid_moves)
  end

  @doc """
  active_piece?/2:  Given a coordinate, does a piece exist there
  and belong to the currently playing player?
  """
  def active_piece?(game_name, coords = {x, y}) when is_integer(x) and is_integer(y) do
    GenServer.call(via_tuple(game_name), {:active_piece?, coords})
  end

  @doc """
  game_summary/1: Return both the game state and "all valid moves."
  %{
    game: %Game{},
    all_valid_moves: [ %Move{}, ... ]
  }
  """
  def game_summary(game_name) do
    GenServer.call(via_tuple(game_name), :game_summary)
  end

  #####################################
  ########### IMPLEMENTATION ##########
  #####################################

  def init({game_name, :hardcoded_cards}) do
    Logger.info("GameServer: Starting a server for game named [#{game_name}] (hardcoded cards).")
    _init(game_name, Game.new(game_name, :hardcoded_cards))
  end

  def init({game_name}) do
    Logger.info("GameServer: Starting a server for game named [#{game_name}].")
    _init(game_name, Game.new(game_name))
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
        :ets.insert(:games, {game.game_name, new_game})
        {:reply, {:ok, new_game}, new_game, @timeout}

      {:error, _} ->
        # ???
        {:reply, {:error, :invalid_move}, game, @timeout}
    end
  end

  def handle_call(:all_valid_moves, _from, game) do
    {:reply, Game.all_valid_moves(game), game, @timeout}
  end

  def handle_call({:active_piece?, coords = {x, y}}, _from, game)
      when is_integer(x) and is_integer(y) do
    response = Game.active_piece?(game, coords)
    {:reply, response, game, @timeout}
  end

  def handle_call(:game_summary, _from, game) do
    reply = %{
      all_valid_moves: Game.all_valid_moves(game),
      game: game
    }

    {:reply, reply, game, @timeout}
  end

  # When timing out, the order is handle_info(:timeout, _) -> terminate({:shutdown, :timeout}, _)
  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  def terminate({:shutdown, :timeout}, game) do
    Logger.info("GameServer: Terminate (Timeout) running for #{game.game_name}")
    :ets.delete(:games, game.game_name)
    :ok
  end

  def terminate(_reason, game) do
    Logger.info("GameServer: Strange termination for [#{game.game_name}].")
    :ok
  end
end
