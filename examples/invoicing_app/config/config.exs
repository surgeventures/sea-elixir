use Mix.Config

config :invoicing_app,
  ecto_repos: [InvoicingApp.Repo]

config :invoicing_app, InvoicingApp.Repo,
  database: "invoicing_app_repo_#{Mix.env()}",
  username: "postgres",
  hostname: "localhost"
