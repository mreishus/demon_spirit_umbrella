defmodule DemonSpiritWeb.PageController do
  use DemonSpiritWeb, :controller

  def index(conn, _params) do
    case conn do
      %{assigns: %{current_guest: _current_guest}} ->
        redirect(conn, to: Routes.game_path(conn, :index))

      %{assigns: %{current_user: _current_user}} ->
        redirect(conn, to: Routes.game_path(conn, :index))

      _ ->
        conn
        |> put_session(:redir_to, conn.request_path)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end
end
