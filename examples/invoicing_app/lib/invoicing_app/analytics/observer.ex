defmodule InvoicingApp.Analytics.Observer do
  use Sea.Observer

  alias InvoicingApp.Repo
  alias InvoicingApp.Sales.InvoiceCreatedSignal
  alias InvoicingApp.Analytics.CustomerInvoiceCounter

  @impl true
  def handle_signal(%InvoiceCreatedSignal{customer_id: customer_id}) do
    Repo.insert!(
      %CustomerInvoiceCounter{customer_id: customer_id, invoice_count: 1},
      conflict_target: :customer_id,
      on_conflict: [inc: [invoice_count: 1]]
    )
  end
end
