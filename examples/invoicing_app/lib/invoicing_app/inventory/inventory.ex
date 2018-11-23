defmodule InvoicingApp.Inventory do
  @moduledoc """
  Inventory system manages products and their stock levels.
  """

  alias __MODULE__.{
    CreateProductService,
    IncreaseStockService
  }

  def create_product do
    CreateProductService.call()
  end

  def increase_stock(product_id, amount \\ 1) do
    IncreaseStockService.call(product_id, amount)
  end
end
