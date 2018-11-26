use Mix.Config

config :invoicing_app,
  ecto_repos: [InvoicingApp.Repo]

config :invoicing_app, InvoicingApp.Repo,
  database: "invoicing_app_repo_#{Mix.env()}",
  username: "postgres",
  hostname: "localhost"

config :invoicing_app, InvoicingApp.Sales.CreateInvoiceService,
  invoice_created_signal: InvoicingApp.Sales.InvoiceCreatedSignal

if Mix.env() == :test do
  config :invoicing_app, InvoicingApp.Repo, pool: Ecto.Adapters.SQL.Sandbox

  config :invoicing_app, InvoicingApp.Sales.CreateInvoiceService,
    invoice_created_signal: InvoicingApp.SignalMock

  config :logger, level: :info
end
