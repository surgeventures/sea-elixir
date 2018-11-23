defmodule InvoicingApp.Inventory.CreateProductService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Inventory.Product

  def call do
    Repo.insert!(%Product{})
  end
end
