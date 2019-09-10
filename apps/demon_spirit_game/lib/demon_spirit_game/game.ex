defmodule DemonSpiritGame.Game do
  @moduledoc """
  Provides a structure to hold all game state, with functions
  to manipulate that state.

  board: Map.  Keys are {x, y} tuples of integers.
     Values are maps representing pieces.
  cards.  Map with the following keys (indented) %Map{
    white: List of 2 %Cards{}.  Moves that white may use.
    black: List of 2 %Cards{}.  Moves that black may use.
    side: One %Card{} that currently belongs to neither player.  Not a list.. should it be?
  }
  turn: Atom, :white or :black, whose turn is it?
  winner: nil, or atom :white or :black.  Who has won?

  Example of cards rotating.
  - White: [Tiger, Crab]  Black: [Monkey, Crane] Side: Mantis
  - White plays a move using the Tiger card.
  - White: [Mantis, Crab]  Black: [Monkey, Crane] Side: Tiger
  - Black plays a move using the Crane card.
  - White: [Mantis, Crab]  Black: [Monkey, Tiger] Side: Crane
  """
  defstruct board: nil,
            cards: %{
              white: [],
              black: [],
              side: nil
            },
            turn: :white,
            winner: nil

  alias DemonSpiritGame.{Game, Card, Move}

  @doc """
  new/0: Create a new game with random cards.

  Input: None
  Output: %Game{}
  """
  @spec new() :: %Game{}
  def new do
    cards = Card.cards() |> Enum.take_random(5)

    %Game{
      board: initial_board(),
      cards: %{
        white: cards |> Enum.slice(0, 2),
        black: cards |> Enum.slice(2, 2),
        side: cards |> Enum.at(4)
      }
    }
  end

  @doc """
  new/1: Create a new game with cards specified.  Provide a list of
  5 cards.  They will be assigned in this order:
  [WHITE, WHITE, BLACK, BLACK, SIDE].

  Input:
    cards: [%Cards{}].  List should be length 5
  Output: %Game{}
  """
  @spec new(nonempty_list(%Card{})) :: %Game{}
  def new(cards) when is_list(cards) and length(cards) == 5 do
    %Game{
      board: initial_board(),
      cards: %{
        white: cards |> Enum.slice(0, 2),
        black: cards |> Enum.slice(2, 2),
        side: cards |> Enum.at(4)
      }
    }
  end

  @doc """
  move/3: Move a piece in the game, if possible.

  **DOESNTWORK
  **NOTEST

  Input:
    game: %Game{}
    from: {x, y} tuple of piece to pick up and move, example: {2, 2} for the center square
    to: {x, y} tuple of destination, example: {3, 2} to move it right one square
  Output:
    {:ok, %Game{}}
  Output (error)
    {:error, _}
  """
  @spec move(%Game{}, %Move{}) :: {:ok, %Game{}} | {:error, any}
  def move(game, move = %Move{}) do
    case valid_move?(game, move) do
      true -> {:ok, game}
      false -> {:error, :invalid_move}
    end
  end

  @doc """
  valid_move?/2:  Given a game state and a move specified by coordinates, is that move valid?

  NOTEST

  Input:
    game: %Game{}
    from: {x, y} tuple of piece to pick up and move, example: {2, 2} for the center square
    to: {x, y} tuple of destination, example: {3, 2} to move it right one square
  Output: Boolean, is this move valid?
  """
  @spec valid_move?(%Game{}, %Move{}) :: boolean()
  def valid_move?(game, move = %Move{from: from, to: to, card: card}) do
    active_piece?(game, from) && valid_coord?(to) && to not in active_piece_coords(game) &&
      card_provides_move?(move)
  end

  @spec card_provides_move?(%Move{}) :: boolean()
  def card_provides_move?(move = %Move{from: from, to: to, card: card}) do
    to in (possible_moves(from, card) |> Enum.map(fn m -> m.to end))
  end

  @doc """
  active_piece?/2:  Given a game state and a coordinate, does a piece exist there
  and belong to the currently playing player?

  Input:
    game: %Game{}
    from: {x, y} tuple of piece to pick up and move, example: {2, 2} for the center square
  Output:
    Boolean: Does the from piece exist, and if so, does it belong to the player whose turn it currently is?
  """
  @spec active_piece?(%Game{}, {integer(), integer()}) :: boolean()
  def active_piece?(game, from) do
    piece = Map.get(game.board, from)
    piece != nil && piece.color == game.turn
  end

  @doc """
  all_valid_moves/1: What are all of the valid moves that a player may currently take?
  """
  @spec all_valid_moves(%Game{}) :: list(%Move{})
  def all_valid_moves(game = %{winner: winner}) when not is_nil(winner), do: []

  def all_valid_moves(game) do
    active_piece_coords = active_piece_coords(game)

    active_piece_coords
    |> Enum.flat_map(fn {x, y} ->
      game.cards.black
      |> Enum.flat_map(fn card ->
        possible_moves({x, y}, card)
      end)
    end)
    |> Enum.filter(&valid_coord?/1)
    |> Enum.filter(fn %Move{to: to} -> to not in active_piece_coords end)
  end

  @doc """
  valid_coord/1
  """
  def valid_coord?(%Move{from: from, to: to}), do: valid_coord?(from) && valid_coord?(to)
  def valid_coord?({x, y}) when x >= 0 and x <= 4 and y >= 0 and y <= 4, do: true
  def valid_coord?(_), do: false

  @doc """
  active_piece_coords/1: What are all of the coordinates of the pieces of the active player?
  All valid moves must begin with one of these as the 'from' piece.

  Input:
    game: %Game{}
  Output:
    list of {x, y} tuples containing integers: All coordinates of peices belonging to the player
    whose turn it currently is.

    iex> DemonSpiritGame.Game.new |> active_piece_coords
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}]
  """
  @spec active_piece_coords(%Game{}) :: list({integer(), integer()})
  def active_piece_coords(game) do
    game.board
    |> Map.to_list()
    |> Enum.filter(fn {coord, %{color: color}} -> color == game.turn end)
    |> Enum.map(fn {coord, _} -> coord end)
  end

  @doc """
  possible_moves/2
  Given a starting coordinate and a card, generate a list of possible moves
  for that piece.

  Input:
    {x, y}: Tuple of two integers representing a starting coordinate
    %Card{}: A Card to use to generate moves
  Output:
    List of %Move{}s.  Possible moves.  Note, some of these may be invalid
    and land on other pieces owned by the player.  That needs to be filtered
    out later.
  """
  @spec possible_moves({integer(), integer()}, %Card{}) :: list(%Move{})
  def possible_moves(_coord, nil), do: []

  def possible_moves({x, y}, card = %Card{}) do
    card.moves
    |> Enum.map(fn {dx, dy} ->
      %Move{from: {x, y}, to: {x + dx, y + dy}, card: card}
    end)
    |> Enum.filter(&valid_coord?/1)
  end

  @doc """
  change_player/1:  Simply flips the ":turn" field of the game between :white and :black.
  Does not flip if there is a winner.  [Unsure if this is correct, it could set winner to nil?]

  Input: %Game{}
  Output: %Game{} with :turn flipped, if there is not a winner.
  """
  @spec change_player(%Game{}) :: %Game{}
  def change_player(game = %{winner: winner}) when not is_nil(winner), do: game
  def change_player(game = %{turn: :white}), do: %{game | turn: :black}
  def change_player(game = %{turn: :black}), do: %{game | turn: :white}

  _ = """
  initial_board: The initial
  setup of the pieces.

          v {4, 4} (top right)
  P P K P P (Black)
  . . . . .
  . . . . .
  . . . . .
  P P K P P (White)
  ^ {0, 0} (bottom left)

  Input: none.
  Output: Map of the format %{ {0, 0} => %{type: :pawn, color: :white}, {x, y} => %{type: ..., color: ... }, ... }
  """

  @spec initial_board() :: map()
  defp initial_board do
    white_pawn = %{type: :pawn, color: :white}
    white_king = %{type: :king, color: :white}
    black_pawn = %{type: :pawn, color: :black}
    black_king = %{type: :king, color: :black}

    %{
      {0, 0} => white_pawn,
      {1, 0} => white_pawn,
      {2, 0} => white_king,
      {3, 0} => white_pawn,
      {4, 0} => white_pawn,
      {0, 4} => black_pawn,
      {1, 4} => black_pawn,
      {2, 4} => black_king,
      {3, 4} => black_pawn,
      {4, 4} => black_pawn
    }
  end
end
