defmodule InvoicingApp.Sales.CreateInvoiceServiceTest do
  use InvoicingApp.DataCase, async: true
  import InvoicingApp.Factories
  import Mox
  alias InvoicingApp.Sales

  test "call/2" do
    stub(InvoicingApp.SignalMock, :emit, fn _ -> :ok end)

    %{id: customer_id} = insert(:customers_account)
    %{id: product_id} = insert(:inventory_product)

    invoice = Sales.create_invoice(product_id, customer_id)

    assert invoice.customer_id == customer_id
    assert invoice.product_id == product_id
    assert invoice.number
  end
end
