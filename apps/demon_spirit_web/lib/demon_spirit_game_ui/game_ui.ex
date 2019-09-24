defmodule DemonSpiritWeb.GameUI do
  alias DemonSpiritGame.{GameServer, GameSupervisor, Move}
  alias DemonSpiritWeb.{GameUI, GameUIOptions}

  @moduledoc """
  Holds the state for DemonSpiritGame.GameUIServer

  game: %Game{} holding the actual game.  This is duplicated, since the GameServer holds it too.
  game_name: t.String() holding the game name.
  all_valid_moves: [ %Move{}, ... ]
  white: any.  Represents the player in the white seat.
  black: any.  Represents the player in the black seat.
  selected: nil, or, The coordinate of the piece that is currently selected.
  move_dest: If a piece is selected, the coordinates of where that piece may move to.
  last_move: nil, or the %Move{} describing the last move taken.
  options: %GameUIOptions{}
  created_at: DateTime
  """
  defstruct game: nil,
            game_name: nil,
            all_valid_moves: [],
            state: nil,
            white: nil,
            black: nil,
            selected: nil,
            move_dest: [],
            last_move: nil,
            options: nil,
            created_at: nil

  @doc """
  new/2: Create a new gameui + game with random cards.

  Input: game_name (string)
  SideEffects:  GameSupervisor is asked to start a GameServer for game.
  Output: %GameUI{}
  """
  def new(game_name, game_opts = %GameUIOptions{}) do
    game_starter = fn game_name -> GameSupervisor.start_game(game_name) end
    _new(game_name, game_opts, game_starter)
  end

  @doc """
  new/2: Create a new gameui + game with hardcoded cards, for deterministic testing.

  Input: game_name (string), :hardcoded_cards
  SideEffects:  GameSupervisor is asked to start a GameServer for game.
  Output: %GameUI{}
  """
  def new(game_name, :hardcoded_cards) do
    game_starter = fn game_name -> GameSupervisor.start_game(game_name, :hardcoded_cards) end
    game_opts = %GameUIOptions{vs: "human"}
    _new(game_name, game_opts, game_starter)
  end

  # _new/3 (private): Create a new gameUI using game_name and callback.
  # Input: game_name(string)
  # Input2: %GameUIOptions{}
  # Input3: Callback to start up a game server. fn game_name -> {:ok, _pid} end
  # Output: %GameUI
  defp _new(game_name, game_opts = %GameUIOptions{}, game_starter) do
    game =
      case GameServer.state(game_name) do
        nil ->
          {:ok, _pid} = game_starter.(game_name)
          GameServer.state(game_name)

        game ->
          game
      end

    all_valid_moves = GameServer.all_valid_moves(game_name)

    %GameUI{
      game: game,
      game_name: game_name,
      all_valid_moves: all_valid_moves,
      white: nil,
      black: prefill_computer_player(game_opts),
      selected: nil,
      move_dest: [],
      created_at: DateTime.utc_now(),
      options: game_opts
    }
  end

  defp prefill_computer_player(game_opts = %GameUIOptions{vs: vs, computer_skill: computer_skill}) do
    case vs do
      "human" ->
        nil

      "computer" ->
        %{
          type: :computer,
          name: "Computer (Level #{Integer.to_string(computer_skill |> div(10))})"
        }
    end
  end

  @doc """
  sit_down_if_possible/2: Try to have `person` sit down in the first available seat.
  Assigns them to :white if empty, then :black if empty.  No change if both
  are occupied.
  Input 1: %GameUI{}
  Input 2: any (Represents a person.  You will need to pass the same thing
                later when they click, so we can be sure it came from a seated
                person.)
  Output: %GameUI{}
  """
  def sit_down_if_possible(gameui, person) do
    cond do
      gameui.white == nil && gameui.black != person ->
        %{gameui | white: person}

      gameui.black == nil && gameui.white != person ->
        %{gameui | black: person}

      true ->
        gameui
    end
  end

  @doc """
  click/3: A person clicked on a square.  If valid and nothing selected, selects that
  square.  If valid and something was already selected, make a move to that square.
  Input 1: %GameUI{}
  Input 2: coords = {int, int}, what square was clicked
  Input 3: any.  Person who clicked.  We will check gameui.white, gameui.black,
           and gameui.game.turn to make sure whoever clicked it, it's their turn.
           Otherwise the click is ignored.  Whatever you pass here, you must have
           passed earlier to a "sit down" function.
  Output: %GameUI{}
  """
  def click(gameui, coords = {x, y}, person) when is_integer(x) and is_integer(y) do
    cond do
      not allowed_to_click?(gameui, person) -> gameui
      gameui.selected == nil -> click_unselected(gameui, coords)
      true -> click_selected(gameui, coords)
    end
  end

  # allowed_to_click?/2
  # Given the current state of the game, is person allowed to click?
  # Returns boolean.
  # Backdoor: If person is :test, then the answer is always yes.
  defp allowed_to_click?(state, person) do
    cond do
      person == :test -> true
      Map.get(state, state.game.turn) == person -> true
      true -> false
    end
  end

  # Clicking while nothing is selected.
  # If there's an active piece there, select it (Update `selected` and `move_dest`)
  # If there isn't, do nothing
  defp click_unselected(state, coords = {x, y}) when is_integer(x) and is_integer(y) do
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

  # Clicking while something is selected.
  # If (from: selected, to: click) a valid move, send the move, update state
  # If it isn't, clear selection
  defp click_selected(state, coords = {x, y}) when is_integer(x) and is_integer(y) do
    candidates = coords_to_moves(state, state.selected, coords)

    case length(candidates) do
      0 ->
        %{state | selected: nil, move_dest: []}

      _ ->
        # TODO: There could be multiple moves!
        # Game always chooses the first one available.  We should
        # ask the user.
        move = candidates |> Enum.at(0)

        apply_move(state, move)
    end
  end

  def apply_move(state, move) do
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

  # Given two sets of coordinates, "from" and "to", find all valid
  # moves between those points. Returns [%Move{}] or [].
  defp coords_to_moves(state, from = {x1, y1}, to = {x2, y2})
       when is_integer(x1) and is_integer(y1) and is_integer(x2) and is_integer(y2) do
    state.all_valid_moves
    |> Enum.filter(fn %Move{from: from_, to: to_} -> from_ == from and to_ == to end)
  end

  def did_move?(gameui1, gameui2) do
    gameui1.last_move != gameui2.last_move
  end

  def computer_next?(gameui) do
    ## Add something about turns here TODO
    gameui.options.vs == "computer"
  end
end