defmodule DemonSpiritWeb.Router do
  use DemonSpiritWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(DemonSpiritWeb.Authenticator)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", DemonSpiritWeb do
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/game", GameController, only: [:new, :create, :show, :index])
    resources("/session", SessionController, only: [:new, :create, :delete], singleton: true)
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemonSpiritWeb do
  #   pipe_through :api
  # end
end
