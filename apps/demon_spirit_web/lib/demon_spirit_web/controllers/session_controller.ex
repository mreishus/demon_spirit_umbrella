defmodule DemonSpiritWeb.SessionController do
  use DemonSpiritWeb, :controller

  def new(conn, _params) do
    guest = DemonSpirit.new_guest()
    render(conn, "new.html", guest: guest)
  end

  def create(conn, %{"guest" => params}) do
    # Guests get a hardcoded random id
    params = Map.put(params, "id", :rand.uniform(10_000_000))

    case DemonSpirit.fake_insert_guest(params) do
      {:ok, guest} ->
        conn
        |> put_session(:current_guest, guest)
        |> put_flash(:info, "Logged in as #{guest.name} (guest).")
        |> redirect_to_destination

      {:error, guest} ->
        conn
        |> put_flash(:error, "Unable to log in as guest.")
        |> render("new.html", guest: guest)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: "/")
  end

  def redirect_to_destination(conn) do
    destination = get_session(conn, :redir_to) || Routes.game_path(conn, :index)

    conn
    |> put_session(:redir_to, nil)
    |> redirect(to: destination)
  end
end
