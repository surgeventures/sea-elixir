defmodule InvoicingApp.Inventory do
  @moduledoc """
  Inventory system manages products and their stock levels.
  """

  alias __MODULE__.{
    CreateProductService,
    IncreaseStockService,
    GetStockService
  }

  def create_product do
    CreateProductService.call()
  end

  def increase_stock(product_id, amount \\ 1) do
    IncreaseStockService.call(product_id, amount)
  end

  def get_stock(product_id) do
    GetStockService.call(product_id)
  end
end
