defmodule DemonSpiritWeb.LiveChatIndex do
  @moduledoc """
  LiveChatIndex: A Live view for showing a chat room on a webpage.
  This is intended to be nestable inside other live views.
  """
  use Phoenix.LiveView
  alias DemonSpiritWeb.{ChatView, Endpoint, Presence}
  alias DemonSpiritGame.{ChatServer, ChatSupervisor}

  def render(assigns) do
    ChatView.render("live_index.html", assigns)
  end

  def mount(%{"chat_name" => chat_name, "guest" => guest}, socket) do
    topic = topic_for(chat_name)
    if connected?(socket), do: Endpoint.subscribe(topic)
    {:ok, _} = Presence.track(self(), topic, guest.id, guest)
    ChatSupervisor.start_chat_if_needed(chat_name)

    {:ok,
     assign(socket,
       guest: guest,
       chat_name: chat_name,
       chat_message: DemonSpirit.new_chat_message(),
       messages: ChatServer.messages(chat_name),
       topic: topic,
       users: []
     )}
  end

  def handle_event(
        "message",
        %{"chat_message" => params},
        socket = %{assigns: %{chat_name: chat_name, guest: guest}}
      ) do
    msg_tuple =
      params
      |> Map.put("name", guest.name)
      |> DemonSpirit.fake_insert_chat_message()

    case msg_tuple do
      {:ok, this_msg} ->
        ChatServer.add_message(chat_name, this_msg)

        notify(socket.assigns.topic)

        {:noreply,
         assign(socket,
           chat_message: DemonSpirit.new_chat_message(),
           messages: ChatServer.messages(chat_name)
         )}

      _ ->
        # Silent failure if e.g. blank message
        {:noreply, socket}
    end
  end

  def notify(topic) do
    Endpoint.broadcast_from(self(), topic, "state_update", %{})
  end

  def topic_for(chat_name) do
    "chat-topic:" <> chat_name
  end

  def handle_info(
        %{event: "state_update"},
        socket = %{assigns: %{chat_name: chat_name}}
      ) do
    messages = ChatServer.messages(chat_name)
    {:noreply, assign(socket, messages: messages)}
  end

  # Handle "presence_diff", someone joined or left
  def handle_info(%{event: "presence_diff"}, socket = %{assigns: %{topic: topic}}) do
    users =
      Presence.list(topic)
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    {:noreply, assign(socket, users: users)}
  end
end
