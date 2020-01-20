defmodule DemonSpiritWeb.ChatController do
  use DemonSpiritWeb, :controller
  alias DemonSpiritWeb.{LiveChatIndex}
  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, LiveChatIndex,
      session: %{"chat_name" => "chat_controller"}
    )
  end
end
