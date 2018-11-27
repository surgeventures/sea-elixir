defmodule InvoicingApp.Sales.CreateInvoiceServiceTest do
  use InvoicingApp.DataCase, async: true
  import InvoicingApp.Factories
  import Mox
  import Sea.SignalMocking
  alias InvoicingApp.Sales
  alias InvoicingApp.Sales.Invoice

  test "call/2" do
    # it's a unit test so we don't want signal to trigger side-effects all over the place...
    disable_signal(InvoicingApp.Sales.InvoiceCreatedSignal)

    # ...but we still expect it to get called with our invoice
    expect(InvoicingApp.Sales.InvoiceCreatedSignal.Mock, :emit, fn %Invoice{} -> :ok end)

    # we use factories to get required records without reaching for external business logic
    %{id: customer_id} = insert(:customers_account)
    %{id: product_id} = insert(:inventory_product)

    # invoice creation would raise if side-effects would execute (we didn't restock the product
    # so the Inventory observer would attempt to break the stock_cannot_be_negative constraint)
    invoice = Sales.create_invoice(product_id, customer_id)

    # and here come our assertions, all beautifully scoped to tested unit
    assert %Invoice{customer_id: ^customer_id, product_id: ^product_id, number: number} = invoice
    assert is_binary(number)
    verify!(InvoicingApp.Sales.InvoiceCreatedSignal.Mock)
  end
end
