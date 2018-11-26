defmodule InvoicingTest do
  use InvoicingApp.DataCase, async: true
  import Mox
  alias InvoicingApp.{Analytics, Customers, Inventory, Sales}

  test "create invoices for many customers until out of stock" do
    stub_with(
      InvoicingApp.SignalMock,
      InvoicingApp.Sales.InvoiceCreatedSignal
    )

    # create product and customers
    product = Inventory.create_product()
    mike = Customers.register_account("Mike")
    jane = Customers.register_account("Jane")

    # ensure we can't sell a product that wasn't ever restocked yet
    assert_raise(Postgrex.Error, fn ->
      Sales.create_invoice(product, jane)
    end)

    # restock and sell
    Inventory.increase_stock(product, 3)
    Sales.create_invoice(product, mike)
    Sales.create_invoice(product, mike)

    # ensure side-effects are called and Analytics & Customers modules keep up
    assert Analytics.get_invoice_count(mike) == 2
    assert Analytics.get_invoice_count(jane) == 0
    assert Customers.active?(mike) == true
    assert Customers.active?(jane) == false

    # again, for the 2nd customer...
    Sales.create_invoice(product, jane)
    assert Analytics.get_invoice_count(jane) == 1
    assert Customers.active?(jane) == true

    # ensure we have depleted the stock and can't sell anymore
    assert_raise(Postgrex.Error, fn ->
      Sales.create_invoice(product, jane)
    end)

    # ensure side-effects have been rolled back when the sale failed due to out of stock
    assert Analytics.get_invoice_count(jane) == 1
  end
end
