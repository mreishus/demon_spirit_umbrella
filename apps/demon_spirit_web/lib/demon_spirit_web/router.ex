defmodule DemonSpiritWeb.Router do
  use DemonSpiritWeb, :router
  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(DemonSpiritWeb.Authenticator)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  ## BEGIN Phoenix LiveDashboard ###
  scope "/" do
    if Mix.env() == :dev do
      pipe_through([:browser])
    else
      pipe_through([:browser, :dash_admins_only])
    end

    live_dashboard("/dashboard")
  end

  pipeline :dash_admins_only do
    plug(:basic_auth, Application.compile_env(:demon_spirit_web, :dash_basic_auth, nil))
  end

  ## END Phoenix LiveDashboard ###

  scope "/", DemonSpiritWeb do
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/game/live_test", GameController, :live_test)
    resources("/game", GameController, only: [:new, :create, :show, :index])
    resources("/session", SessionController, only: [:new, :create, :delete], singleton: true)
    resources("/chat", ChatController, only: [:index])
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemonSpiritWeb do
  #   pipe_through :api
  # end
end
