defmodule InvoicingAppTest do
  use ExUnit.Case
  alias InvoicingApp.{Analytics, Customers, Inventory, Sales}

  test "integration example" do
    product = Inventory.create_product()
    mike = Customers.register_account("Mike")
    jane = Customers.register_account("Jane")

    Inventory.increase_stock(product, 3)
    Sales.create_invoice(product, mike)
    Sales.create_invoice(product, mike)

    assert Analytics.get_invoice_count(mike) == 2
    assert Analytics.get_invoice_count(jane) == 0
    assert Customers.active?(mike) == true
    assert Customers.active?(jane) == false

    Sales.create_invoice(product, jane)

    assert Analytics.get_invoice_count(jane) == 1
    assert Customers.active?(jane) == true

    assert_raise(Postgrex.Error, fn ->
      Sales.create_invoice(product, jane)
    end)

    assert Analytics.get_invoice_count(jane) == 1
  end
end
