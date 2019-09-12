defmodule DemonSpiritWeb.SessionController do
  use DemonSpiritWeb, :controller
  alias DemonSpirit.Guest

  def new(conn, _params) do
    guest = DemonSpirit.new_guest()
    render(conn, "new.html", guest: guest)
  end

  def create(conn, %{"guest" => params}) do
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
    # TODO: Make smarter
    conn
    |> redirect(to: "/")
  end
end
