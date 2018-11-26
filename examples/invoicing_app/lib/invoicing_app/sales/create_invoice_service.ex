defmodule InvoicingApp.Sales.CreateInvoiceService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Sales.Invoice

  @invoice_created_signal InvoicingApp.get_mod_config_key(__MODULE__, :invoice_created_signal)

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

      @invoice_created_signal.emit(invoice)

      invoice
    end)
    |> elem(1)
  end
end
