defmodule DemonSpiritWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use DemonSpiritWeb, :controller
      use DemonSpiritWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  alias DemonSpiritWeb.GameUIOptions

  def controller do
    quote do
      use Phoenix.Controller, namespace: DemonSpiritWeb
      import Plug.Conn
      import DemonSpiritWeb.Gettext
      alias DemonSpiritWeb.Router.Helpers, as: Routes
      import Phoenix.LiveView.Controller, only: [live_render: 3]
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/demon_spirit_web/templates",
        namespace: DemonSpiritWeb,
        pattern: "**/*"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import DemonSpiritWeb.ErrorHelpers
      import DemonSpiritWeb.Gettext
      alias DemonSpiritWeb.Router.Helpers, as: Routes

      import Phoenix.LiveView.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import DemonSpiritWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  @doc """
  Use ecto w/o DB to validate incoming game options
  Input: %{"vs" => "computer", ... other options ... }
  OUTPUT: {:ok, %GameUIOptions{}}
  """
  def validate_game_ui_options(params) do
    %GameUIOptions{}
    |> GameUIOptions.changeset(params)
    |> Ecto.Changeset.apply_action(:insert)
  end
end
