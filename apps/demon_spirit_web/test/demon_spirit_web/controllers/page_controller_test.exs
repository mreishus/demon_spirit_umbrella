defmodule DemonSpiritWeb.PageControllerTest do
  use DemonSpiritWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "redirected"
  end
end
