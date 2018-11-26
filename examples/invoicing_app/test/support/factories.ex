defmodule InvoicingApp.Factories do
  use ExMachina.Ecto, repo: InvoicingApp.Repo

  def customers_account_factory do
    %InvoicingApp.Customers.Account{
      name: "Jane Smith"
    }
  end

  def inventory_product_factory do
    %InvoicingApp.Inventory.Product{}
  end
end
