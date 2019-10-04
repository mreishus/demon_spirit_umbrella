defmodule DemonSpiritWeb.GameController do
  use DemonSpiritWeb, :controller

  alias DemonSpiritWeb.{
    GameUIServer,
    GameUISupervisor,
    LiveGameIndex,
    LiveGameShow,
    NameGenerator
  }

  alias Phoenix.LiveView

  plug(:require_logged_in)

  def index(conn, _params) do
    guest = conn.assigns.current_guest
    LiveView.Controller.live_render(conn, LiveGameIndex, session: %{guest: guest})
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"game_opts" => game_opts}) do
    game_name = NameGenerator.generate()
    {:ok, game_opts} = DemonSpiritWeb.validate_game_ui_options(game_opts)

    case GameUISupervisor.start_game(game_name, game_opts) do
      {:ok, _pid} ->
        redirect(conn, to: Routes.game_path(conn, :show, game_name))

      {:error, _} ->
        conn
        |> put_flash(:error, "Unable to start game.")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  def show(conn, %{"id" => game_name}) do
    state = GameUIServer.state(game_name)
    guest = conn.assigns.current_guest

    case state do
      nil ->
        conn
        |> put_flash(:error, "Game does not exist")
        |> redirect(to: Routes.game_path(conn, :new))

      _ ->
        LiveView.Controller.live_render(conn, LiveGameShow,
          session: %{game_name: game_name, guest: guest}
        )
    end
  end

  defp require_logged_in(conn = %{assigns: %{current_user: current_user}}, _opts)
       when not is_nil(current_user) do
    conn
  end

  defp require_logged_in(conn = %{assigns: %{current_guest: current_guest}}, _opts)
       when not is_nil(current_guest) do
    conn
  end

  defp require_logged_in(conn, _opts) do
    conn
    |> put_flash(:info, "Please log in first.")
    |> put_session(:redir_to, conn.request_path)
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
end
