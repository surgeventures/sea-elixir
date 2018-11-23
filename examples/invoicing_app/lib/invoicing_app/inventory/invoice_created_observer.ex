defmodule InvoicingApp.Inventory.InvoiceCreatedObserver do
  use Sea.Observer

  alias InvoicingApp.Inventory.IncreaseStockService
  alias InvoicingApp.Sales.InvoiceCreatedSignal

  @impl true
  def handle_signal(%InvoiceCreatedSignal{product_id: product_id}) do
    IncreaseStockService.call(product_id, -1)
  end
end
