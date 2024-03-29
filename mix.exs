defmodule DemonSpirit.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      version: "0.1.0",
      releases: [
        demon_spirit_umbrella: [
          applications: [
            demon_spirit_web: :permanent,
            demon_spirit_game: :permanent,
            demon_spirit: :permanent
          ]
        ]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:ex_check, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 1.0.0", only: :dev, runtime: false},
      # Temporarily set the manager option for this so it compiles
      # https://elixirforum.com/t/elixir-v1-15-0-released/56584/4?u=axelson
      {:ssl_verify_fun, ">= 0.0.0", manager: :rebar3, override: true}
    ]
  end
end
