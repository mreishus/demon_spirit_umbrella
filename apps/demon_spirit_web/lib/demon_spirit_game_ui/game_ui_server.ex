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

  defmodule State do
    @moduledoc """
    Holds the state for DemonSpiritGame.GameUIServer
    game: %Game{} holding the actual game.  This is duplicated, since the GameServer holds it too.
    game_name: t.String() holding the game name.
    all_valid_moves: [ %Move{}, ... ]
    state: :waiting | :selected (?) ( Might not be needed if we have "selected" )
    selected: nil, or, The coordinate of the piece that is currently selected.
    move_dest: If a piece is selected, the coordinates of where that piece may move to.
    last_move: nil, or the %Move{} describing the last move taken.
    """
    defstruct game: nil,
              game_name: nil,
              all_valid_moves: [],
              state: nil,
              white: nil,
              black: nil,
              selected: nil,
              move_dest: [],
              last_move: nil
  end

  use GenServer
  @timeout :timer.hours(2)
  @timeout_game_won :timer.minutes(5)

  require Logger
  alias DemonSpiritGame.{GameServer, GameSupervisor, Move}
  alias DemonSpiritWeb.GameRegistry

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
  click/2: ...
  """
  def click(game_name, coords = {x, y}) when is_integer(x) and is_integer(y) do
    GenServer.call(via_tuple(game_name), {:click, coords})
  end

  ####### IMPLEMENTATION #######

  def init({game_name}) do
    game_starter = fn game_name -> GameSupervisor.start_game(game_name) end
    _init(game_name, game_starter)
  end

  def init({game_name, :hardcoded_cards}) do
    game_starter = fn game_name -> GameSupervisor.start_game(game_name, :hardcoded_cards) end
    _init(game_name, game_starter)
  end

  defp _init(game_name, game_starter) do
    game =
      case GameServer.state(game_name) do
        nil ->
          {:ok, _pid} = game_starter.(game_name)
          GameServer.state(game_name)

        game ->
          game
      end

    all_valid_moves = GameServer.all_valid_moves(game_name)

    state = %State{
      game: game,
      game_name: game_name,
      all_valid_moves: all_valid_moves,
      state: :waiting,
      white: nil,
      black: nil,
      selected: nil,
      move_dest: []
    }

    GameRegistry.add(game_name)
    {:ok, state, timeout(state)}
  end

  # Clicking while something is selected.
  # If (from: selected, to: click) a valid move, send the move, update state
  # If it isn't, clear selection
  defp click_selected(coords = {x, y}, state) when is_integer(x) and is_integer(y) do
    candidates = coords_to_moves(state, state.selected, coords)

    case length(candidates) do
      0 ->
        %{state | selected: nil, move_dest: []}

      _ ->
        # TODO: There could be multiple moves!
        # Game always chooses the first one available.  We should
        # ask the user.
        move = candidates |> Enum.at(0)
        response = GameServer.move(state.game_name, move)

        case response do
          {:ok, new_game} ->
            all_valid_moves = GameServer.all_valid_moves(state.game_name)

            %{
              state
              | game: new_game,
                all_valid_moves: all_valid_moves,
                selected: nil,
                move_dest: [],
                last_move: move
            }

          {:error, _} ->
            %{state | selected: nil, move_dest: []}
        end
    end
  end

  # Clicking while nothing is selected.
  # If there's an active piece there, select it
  # If there isn't, do nothing
  defp click_unselected(coords = {x, y}, state) when is_integer(x) and is_integer(y) do
    case GameServer.active_piece?(state.game_name, coords) do
      true ->
        %{state | selected: coords, move_dest: move_dest(coords, state)}

      false ->
        state
    end
  end

  # Given one set of coordinates, "from", find all valid destinationss
  # for that piece.  Returns [{x, y}] or []
  defp move_dest(coords = {x, y}, state) when is_integer(x) and is_integer(y) do
    state.all_valid_moves
    |> Enum.filter(fn %Move{from: from_} -> from_ == coords end)
    |> Enum.map(fn m = %Move{} -> m.to end)
  end

  # Given two sets of coordinates, "from" and "to", find all valid
  # moves between those points. Returns [%Move{}] or [].
  defp coords_to_moves(state, from = {x1, y1}, to = {x2, y2})
       when is_integer(x1) and is_integer(y1) and is_integer(x2) and is_integer(y2) do
    state.all_valid_moves
    |> Enum.filter(fn %Move{from: from_, to: to_} -> from_ == from and to_ == to end)
  end

  def handle_call({:click, coords = {x, y}}, _from, state)
      when is_integer(x) and is_integer(y) do
    new_state =
      case state.selected do
        nil -> click_unselected(coords, state)
        _ -> click_selected(coords, state)
      end

    {:reply, new_state, new_state, timeout(new_state)}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state, timeout(state)}
  end

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
