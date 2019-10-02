defmodule DemonSpiritWeb.GameUIServer do
  @moduledoc """
  GameUIServer is meant to be one layer above the GameServer.

  The GameServer only cares about the game state.  You feed it moves, it
  updates the board state, and looks for winners.

  The GameUIServer takes click events, marks squares as selected, and listens
  for a second click to move that piece.  It will also display where a piece
  can move to.  It also handles "Drag and Drop" events and the "ready button".

  It will spin up a GameServer and communicate with it to handle the actual
  moves and board state, but it holds its own state on top.

  I'm a little wary about the extra complexity, but it seemed like a waste to
  add "click" and "selected" logic to %Game{} when it already handled everything
  else well in a small package.  It just seemed wasteful/bloated.  For example, an AI
  engine could use %Game{} in its current state without caring about any of the
  stuff we have here.  I also could have put it in the liveView, but that
  didn't seem like the right place either.
  """

  use GenServer
  @timeout :timer.hours(1)
  @timeout_game_won :timer.minutes(5)
  @timeout_game_staging :timer.minutes(10)
  @timeout_unknown :timer.minutes(15)

  require Logger
  alias DemonSpiritGame.{GameSupervisor, AI}
  alias DemonSpiritWeb.{GameRegistry, GameUI, GameUIOptions, GameInfo, LiveGameShow}

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
  stand_up_if_possible/2: Stand up from a seat if the game hasn't started yet.
  Returns state.
  """
  # @spec stand_up_if_possible(any) :: %Game{}
  def stand_up_if_possible(game_name, person) do
    GenServer.call(via_tuple(game_name), {:stand_up_if_possible, person})
  end

  @doc """
  ready/2: Person clicked ready.
  """
  # @spec ready(any) :: %Game{}
  def ready(game_name, person) do
    GenServer.call(via_tuple(game_name), {:ready, person})
  end

  @doc """
  not_ready/2: Person clicked not_ready.
  """
  # @spec not_ready(any) :: %Game{}
  def not_ready(game_name, person) do
    GenServer.call(via_tuple(game_name), {:not_ready, person})
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

  @doc """
  drag_start/3: A person has started dragging a piece. Updates the UI to 
  have that piece selected and destination squares highlighted.
  Input: game_name (string)
  Input: source: {integer, integer} coordinates of square dragged
  Input: person: any, who did it
  Output: %GameUI{}
  """
  def drag_start(game_name, source = {sx, sy}, person)
      when is_integer(sx) and is_integer(sy) do
    GenServer.call(via_tuple(game_name), {:drag_start, source, person})
  end

  @doc """
  drag_end/3: A person has canceled or ended their drag. Removes the
  selected state.
  Input: game_name (string)
  Input: Person: any, who did it
  Output: %GameUI{}
  """
  def drag_end(game_name, person) do
    GenServer.call(via_tuple(game_name), {:drag_end, person})
  end

  @doc """
  drag_drop/4: A person has finished a drag/drop event. Makes the desired move
  if possible
  Input: game_name (string)
  Input: source {integer, integer} coordinates of beginning of drag/drop
  Input: target {integer, integer} coordinates of end of drag/drop
  Output: %GameUI{}
  """
  def drag_drop(game_name, source = {sx, sy}, target = {tx, ty}, person)
      when is_integer(sx) and is_integer(sy) and
             is_integer(tx) and is_integer(ty) do
    GenServer.call(via_tuple(game_name), {:drag_drop, source, target, person})
  end

  @doc """
  clarify_move/3: `person` has choosen a move from the clarification popup.
  Sometimes when someone specifies a move using two squares (0,0) -> (0,1), there
  are multiple moves that can be done to that specification.

  We put the user in a 'clarification' state by putting a list of moves in 
  gameui.moves_need_clarify, which shows a modal on the player's UI. When they
  choose a move, call this function.

  input: game_name (string)
  input: i (integer) Index of which move they chose, 0 indexed.
  output: %GameUI{}
  """
  def clarify_move(game_name, i, person) when is_integer(i) do
    GenServer.call(via_tuple(game_name), {:clarify_move, i, person})
  end

  @doc """
  clarify_cancel/2: `person` wants to cancel the clarification state
  and choose a different move.
  input: game_name (string)
  input: person (any)
  output: %GameUI{}
  """
  def clarify_cancel(game_name, person) do
    GenServer.call(via_tuple(game_name), {:clarify_cancel, person})
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
      winner: state.game.winner,
      status: state.status
    }
  end

  def handle_call({:click, coords = {x, y}, person}, _from, gameui)
      when is_integer(x) and is_integer(y) do
    new_gameui = GameUI.click(gameui, coords, person)
    GameRegistry.update(new_gameui.game_name, game_info(new_gameui))

    trigger_ai_move(gameui, new_gameui)

    {:reply, new_gameui, new_gameui, timeout(new_gameui)}
  end

  def handle_call({:drag_start, source = {sx, sy}, person}, _from, gameui)
      when is_integer(sx) and is_integer(sy) do
    new_gameui = GameUI.drag_start(gameui, source, person)
    {:reply, new_gameui, new_gameui, timeout(new_gameui)}
  end

  def handle_call({:drag_end, person}, _from, gameui) do
    new_gameui = GameUI.drag_end(gameui, person)
    {:reply, new_gameui, new_gameui, timeout(new_gameui)}
  end

  def handle_call({:drag_drop, source = {sx, sy}, target = {tx, ty}, person}, _from, gameui)
      when is_integer(sx) and is_integer(sy) and
             is_integer(tx) and is_integer(ty) do
    new_gameui = GameUI.drag_drop(gameui, source, target, person)
    GameRegistry.update(new_gameui.game_name, game_info(new_gameui))
    trigger_ai_move(gameui, new_gameui)
    {:reply, new_gameui, new_gameui, timeout(new_gameui)}
  end

  def handle_call({:clarify_move, i, person}, _from, gameui) when is_integer(i) do
    new_gameui = GameUI.clarify_move(gameui, i, person)
    GameRegistry.update(new_gameui.game_name, game_info(new_gameui))
    trigger_ai_move(gameui, new_gameui)
    {:reply, new_gameui, new_gameui, timeout(new_gameui)}
  end

  def handle_call({:clarify_cancel, person}, _from, gameui) do
    new_gameui = GameUI.clarify_cancel(gameui, person)
    {:reply, new_gameui, new_gameui, timeout(new_gameui)}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state, timeout(state)}
  end

  def handle_call(:ai_move, _from, state) do
    pid = self()

    ## Compute AI move, in the background..
    spawn_link(fn ->
      ai_info = state.game |> AI.alphabeta_skill(state.options.computer_skill)
      move = ai_info.move
      GenServer.call(pid, {:apply_move, move})

      ## Tell the LiveView controller that a move has been made.
      ## This is a little bit of tight coupling, but it 
      ## beats my earlier polling solution.
      state.game_name |> LiveGameShow.topic_for() |> LiveGameShow.notify()
    end)

    {:reply, state, state, timeout(state)}
  end

  def handle_call({:apply_move, nil}, _from, state) do
    {:reply, state, state, timeout(state)}
  end

  def handle_call({:apply_move, move}, _from, gameui) do
    gameui = GameUI.apply_move(gameui, move)
    GameRegistry.update(gameui.game_name, game_info(gameui))
    {:reply, gameui, gameui, timeout(gameui)}
  end

  def handle_call({:sit_down_if_possible, person}, _from, gameui) do
    gameui = GameUI.sit_down_if_possible(gameui, person)
    GameRegistry.update(gameui.game_name, game_info(gameui))
    {:reply, gameui, gameui, timeout(gameui)}
  end

  def handle_call({:stand_up_if_possible, person}, _from, gameui) do
    gameui = GameUI.stand_up_if_possible(gameui, person)
    GameRegistry.update(gameui.game_name, game_info(gameui))
    {:reply, gameui, gameui, timeout(gameui)}
  end

  def handle_call({:ready, person}, _from, gameui) do
    gameui = GameUI.ready(gameui, person)
    GameRegistry.update(gameui.game_name, game_info(gameui))
    {:reply, gameui, gameui, timeout(gameui)}
  end

  def handle_call({:not_ready, person}, _from, gameui) do
    gameui = GameUI.not_ready(gameui, person)
    GameRegistry.update(gameui.game_name, game_info(gameui))
    {:reply, gameui, gameui, timeout(gameui)}
  end

  # trigger_ai_move/2
  # Takes two game states.
  # Looks to see if a move occured between the states.
  # If a move did occur, and the computer is due to play next, sends an ":ai_move" message
  # to self.
  # Basically, this needs to be called whenever we might have processed a move,
  # in order to keep the computer playing.
  defp trigger_ai_move(gameui, new_gameui) do
    if GameUI.did_move?(gameui, new_gameui) and GameUI.computer_next?(new_gameui) do
      pid = self()

      spawn_link(fn ->
        GenServer.call(pid, :ai_move)
      end)
    end
  end

  # timeout/1
  # Given the current state of the game, what should the
  # GenServer timeout be? (Games with winners expire quickly)
  defp timeout(state) do
    case state.status do
      :done ->
        @timeout_game_won

      :staging ->
        @timeout_game_staging

      :playing ->
        @timeout

      _ ->
        @timeout_unknown
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
    :ok
  end

  # Do I need to trap exits here?
  def terminate(_reason, state) do
    Logger.info("Terminate (Non Timeout) running for #{state.game_name}")
    GameRegistry.remove(state.game_name)
    :ok
  end
end
