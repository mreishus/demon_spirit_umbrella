defmodule DemonSpiritWeb.GameUIServer do
  @moduledoc """
  GameUIServer is meant to be one layer above the GameServer.

  The GameServer only cares about the game state.  You feed it moves, it
  updates the board state, and looks for winners.

  The GameUIServer takes click events, marks squares as selected, and listens
  for a second click to move that piece.  It will also display where a piece
  can move to.

  It will spin up a GameServer and communicate with it to handle the actual
  moves and board state, but it holds its own state on top.

  I'm a little wary about the extra complexity, but it seemed like a waste to
  add "click" and "selected" logic to %Game{} when it already handled everything
  else well in a small package.  It just seemed wasteful/bloated.  For example, an AI
  engine could use %Game{} in its current state without caring about any of the
  stuff we have here.  I also could have put it in the liveView, but that
  didn't seem like the right place either.
  """

  defmodule GameInfo do
    defstruct name: nil, created_at: nil, white: nil, black: nil, winner: nil
  end

  use GenServer
  @timeout :timer.hours(2)
  @timeout_game_won :timer.minutes(5)

  require Logger
  alias DemonSpiritGame.{GameSupervisor}
  alias DemonSpiritWeb.{GameRegistry, GameUI, GameUIOptions}

  alias DemonSpiritGame.{AI, GameServer}

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
  start_link/2: Generates a new game server under a provided name.
  """
  # Using type specs in genserver causes my app to not compile..??
  # @spec start_link(t.String, %GameUIOptions{}) :: {:ok, pid} | {:error, any}
  def start_link(game_name, game_opts = %GameUIOptions{}) do
    GenServer.start_link(__MODULE__, {game_name, game_opts}, name: via_tuple(game_name))
  end

  @doc """
  via_tuple/1: Given a game name string, generate a via tuple for addressing the game.
  """
  def via_tuple(game_name),
    do: {:via, Registry, {DemonSpiritWeb.GameUIRegistry, {__MODULE__, game_name}}}

  @doc """
  gameui_pid/1: Returns the `pid` of the game server process registered
  under the given `game_name`, or `nil` if no process is registered.
  """
  def gameui_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  @doc """
  state/1:  Retrieves the game state for the game under a provided name.
  """
  # @spec state(t.String) :: %Game{}
  def state(game_name) do
    case gameui_pid(game_name) do
      nil -> nil
      _ -> GenServer.call(via_tuple(game_name), :state)
    end
  end

  @doc """
  sit_down_if_possible/2: A game has two seats, White and Black.
  Takes a person object (can be anything) and assigns it to white if white is empty,
  otherwise assigns to black if black is empty, otherwise does nothing.
  Returns state.
  """
  # @spec sit_down_if_possible(any) :: %Game{}
  def sit_down_if_possible(game_name, person) do
    GenServer.call(via_tuple(game_name), {:sit_down_if_possible, person})
  end

  @doc """
  click/3: A person has clicked on square {x, y}.
  Inputs:
     game_name (String)
     coords (Tuple of two integers, like {0, 0} or {4, 4}) - Which square is clicked
     person (Any). Who clicked it.  Compared to what was sent to "sit_down_if_possible" earlier
  Output: State
  """
  def click(game_name, coords = {x, y}, person) when is_integer(x) and is_integer(y) do
    GenServer.call(via_tuple(game_name), {:click, coords, person})
  end

  ####### IMPLEMENTATION #######

  def init({game_name, :hardcoded_cards}) do
    GameUI.new(game_name, :hardcoded_cards)
    |> _init()
  end

  def init({game_name, game_opts = %GameUIOptions{}}) do
    GameUI.new(game_name, game_opts)
    |> _init()
  end

  defp _init(gameui) do
    GameRegistry.add(gameui.game_name, game_info(gameui))
    {:ok, gameui, timeout(gameui)}
  end

  defp game_info(state) do
    %GameInfo{
      name: state.game_name,
      created_at: state.created_at,
      white: state.white,
      black: state.black,
      winner: state.game.winner
    }
  end

  def handle_call({:click, coords = {x, y}, person}, _from, gameui)
      when is_integer(x) and is_integer(y) do
    new_gameui = GameUI.click(gameui, coords, person)

    if GameUI.did_move?(gameui, new_gameui) and GameUI.computer_next?(new_gameui) do
      pid = self()

      spawn_link(fn ->
        GenServer.call(pid, :ai_move)
      end)
    end

    {:reply, new_gameui, new_gameui, timeout(new_gameui)}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state, timeout(state)}
  end

  def handle_call(:ai_move, _from, state) do
    depth =
      case state.options.computer_level do
        1 -> 2
        2 -> 3
        3 -> 5
        4 -> 9
      end

    pid = self()

    ## Compute AI move, in the background..
    ## I don't know how to notify the front-end when this is
    ## finished, though.
    spawn_link(fn ->
      ai_info = state.game |> AI.alphabeta(depth)
      move = ai_info.move
      GenServer.call(pid, {:apply_move, move})
    end)

    {:reply, state, state, timeout(state)}
  end

  def handle_call({:apply_move, move}, _from, state) do
    # TODO: Move this into GameUI.
    {:ok, new_game} = GameServer.move(state.game_name, move)
    all_valid_moves = GameServer.all_valid_moves(state.game_name)

    state = %{
      state
      | game: new_game,
        all_valid_moves: all_valid_moves,
        selected: nil,
        move_dest: [],
        last_move: move
    }

    {:reply, state, state, timeout(state)}
  end

  def handle_call({:sit_down_if_possible, person}, _from, gameui) do
    gameui = GameUI.sit_down_if_possible(gameui, person)
    GameRegistry.update(gameui.game_name, game_info(gameui))
    {:reply, gameui, gameui, timeout(gameui)}
  end

  # timeout/1
  # Given the current state of the game, what should the
  # GenServer timeout be? (Games with winners expire quickly)
  defp timeout(state) do
    case state.game.winner do
      nil -> @timeout
      _ -> @timeout_game_won
    end
  end

  # When timing out, the order is handle_info(:timeout, _) -> terminate({:shutdown, :timeout}, _)
  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, state) do
    Logger.info("Terminate (Timeout) running for #{state.game_name}")
    GameSupervisor.stop_game(state.game_name)
    GameRegistry.remove(state.game_name)
    # TODO: Double check that GameSupervisor is killing the ETS table
    :ok
  end

  # Do I need to trap exits here?
  def terminate(_reason, state) do
    Logger.info("Terminate (Non Timeout) running for #{state.game_name}")
    GameRegistry.remove(state.game_name)
    :ok
  end
end
