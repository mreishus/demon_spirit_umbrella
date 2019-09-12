defmodule DemonSpiritWeb.GameController do
  use DemonSpiritWeb, :controller
  alias DemonSpiritGame.{GameSupervisor, GameServer}
  alias Phoenix.LiveView

  plug(:require_logged_in)

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, _params) do
    game_name = "game-#{:rand.uniform(1000)}"

    case GameSupervisor.start_game(game_name) do
      {:ok, _pid} ->
        redirect(conn, to: Routes.game_path(conn, :show, game_name))

      {:error, _} ->
        conn
        |> put_flash(:error, "Unable to start game.")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  def live_test(conn, _) do
    LiveView.Controller.live_render(conn, DemonSpiritWeb.GithubDeployView, session: %{})
  end

  def show(conn, %{"id" => game_name}) do
    state = GameServer.state(game_name)

    case state do
      nil ->
        conn
        |> put_flash(:error, "Game does not exist")
        |> redirect(to: Routes.game_path(conn, :new))

      _ ->
        render(conn, "show.html", state: state)
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
    |> put_flash(:error, "Must be logged in")
    |> redirect(to: "/")
    |> halt()
  end
end
