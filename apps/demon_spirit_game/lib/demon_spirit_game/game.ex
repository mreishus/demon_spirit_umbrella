defmodule DemonSpiritGame.Game do
  @moduledoc """
  Provides a structure to hold all game state, with functions
  to manipulate that state.

  board: Map.  Keys are {x, y} tuples of integers.
     Values are maps representing pieces.
  white_cards: List of 2 %Cards{}.  Moves that white may use.
  black_cards: List of 2 %Cards{}.  Moves that black may use.
  side_card: One %Card{} that currently belongs to neither player.
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
            white_cards: [],
            black_cards: [],
            side_card: nil,
            turn: :white,
            winner: nil

  alias DemonSpiritGame.{Game, Card}

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
      white_cards: cards |> Enum.slice(0, 2),
      black_cards: cards |> Enum.slice(2, 2),
      side_card: cards |> Enum.at(4)
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
      white_cards: cards |> Enum.slice(0, 2),
      black_cards: cards |> Enum.slice(2, 2),
      side_card: cards |> Enum.at(4)
    }
  end

  @doc """
  move/3: Move a piece in the game, if possible.

  Input:
    game: %Game{}
    from: {x, y} tuple of piece to pick up and move, example: {2, 2} for the center square
    to: {x, y} tuple of destination, example: {3, 2} to move it right one square
  Output:
    {:ok, %Game{}}
  Output (error)
    {:error, _}
  """
  def move(game, from, to) do
    case valid_move(game, from, to) do
      true -> {:ok, game}
      false -> {:error, :invalid_move}
    end
  end

  @doc """
  valid_mode/3:  Given a game state and a move specified by coordinates, is that move valid?

  Input:
    game: %Game{}
    from: {x, y} tuple of piece to pick up and move, example: {2, 2} for the center square
    to: {x, y} tuple of destination, example: {3, 2} to move it right one square
  Output: Boolean, is this move valid?
  """
  @spec valid_move(%Game{}, {integer(), integer()}, {integer(), integer()}) :: boolean()
  def valid_move(game, from, to) do
    valid_move_piece_exists(game, from)
  end

  @doc """
  valid_move_piece_exists/2:  Given a game state and a piece to move, does that piece exist and belong
  to the currently playing player?

  Input:
    game: %Game{}
    from: {x, y} tuple of piece to pick up and move, example: {2, 2} for the center square
  Output:
    Boolean: Does the from piece exist, and if so, does it belong to the player whose turn it currently is?
  """
  @spec valid_move_piece_exists(%Game{}, {integer(), integer()}) :: boolean()
  def valid_move_piece_exists(game, from) do
    piece = Map.get(game.board, from)
    piece != nil && piece.color == game.turn
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
