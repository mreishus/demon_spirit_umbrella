defmodule DemonSpiritWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :demon_spirit_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DemonSpiritWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.18.18"},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.23"},
      {:demon_spirit, in_umbrella: true},
      {:demon_spirit_game, in_umbrella: true},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},
      {:accessible, "~> 0.3.0"},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, we extend the test task to create and migrate the database.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    # [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
