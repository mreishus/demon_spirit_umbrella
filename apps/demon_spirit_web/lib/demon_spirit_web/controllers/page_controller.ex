defmodule DemonSpiritWeb.PageController do
  use DemonSpiritWeb, :controller

  def index(conn, _params) do
    case conn do
      %{assigns: %{current_guest: _current_guest}} ->
        redirect(conn, to: Routes.game_path(conn, :index))

      %{assigns: %{current_user: _current_user}} ->
        redirect(conn, to: Routes.game_path(conn, :index))

      _ ->
        redirect(conn, to: Routes.session_path(conn, :new))
    end
  end
end
