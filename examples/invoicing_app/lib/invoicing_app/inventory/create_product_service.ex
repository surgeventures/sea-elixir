defmodule InvoicingApp.Inventory.CreateProductService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Inventory.Product

  def call do
    product = Repo.insert!(%Product{})
    product.id
  end
end
