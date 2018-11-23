defmodule InvoicingApp.Repo do
  use Ecto.Repo,
    otp_app: :invoicing_app,
    adapter: Ecto.Adapters.Postgres
end
