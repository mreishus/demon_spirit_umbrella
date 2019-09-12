defmodule DemonSpiritWeb.Authenticator do
  @moduledoc """
  Authenticator looks for guest or user information in the
  session, and moves it to "assigns" of the connection.

  Note:  The entire Guest object is stored in the session,
  because it is not persisted anywhere!
  """
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _opts) do
    # User case (?)
    # user =
    #   conn
    #   |> get_session(:user_id)
    #   |> case do
    #     nil -> nil
    #     id -> Auction.get_user(id)
    #   end
    user = nil
    guest = conn |> get_session(:current_guest)

    conn
    |> assign(:current_user, user)
    |> assign(:current_guest, guest)
  end
end
