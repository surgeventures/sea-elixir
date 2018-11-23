defmodule InvoicingApp.Customers.InvoiceCreatedObserver do
  use Sea.Observer

  alias Ecto.Changeset
  alias InvoicingApp.Repo
  alias InvoicingApp.Customers.Account
  alias InvoicingApp.Sales.InvoiceCreatedSignal

  @impl true
  def handle_signal(%InvoiceCreatedSignal{customer_id: account_id}) do
    Account
    |> Repo.get!(account_id)
    |> Changeset.change(active: true)
    |> Repo.update!()
  end
end
