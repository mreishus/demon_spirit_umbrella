[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["apps/*"]
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
