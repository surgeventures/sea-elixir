defmodule InvoicingApp.Sales.InvoiceCreatedSignal do
  use Sea.Signal

  emit_within(InvoicingApp.{Analytics, Customers, Inventory})

  defstruct [:customer_id, :product_id]

  def build(%InvoicingApp.Sales.Invoice{customer_id: customer_id, product_id: product_id}) do
    %__MODULE__{
      customer_id: customer_id,
      product_id: product_id
    }
  end
end
