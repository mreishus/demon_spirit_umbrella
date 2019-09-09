defmodule DemonSpiritWeb.PageController do
  use DemonSpiritWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
