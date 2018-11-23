defmodule InvoicingApp.Sales.CreateInvoiceService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Sales.{Invoice, InvoiceCreatedSignal}

  def call(product_id, customer_id) do
    invoice_attrs = [
      product_id: product_id,
      customer_id: customer_id
    ]

    Repo.transaction(fn ->
      invoice =
        invoice_attrs
        |> Invoice.changeset()
        |> Repo.insert!()

      InvoiceCreatedSignal.emit(invoice)
    end)
  end
end
