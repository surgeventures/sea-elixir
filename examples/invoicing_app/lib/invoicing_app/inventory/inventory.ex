defmodule InvoicingApp.Inventory do
  @moduledoc """
  Inventory system manages products and their stock levels.
  """

  use InvoicingApp.SignalRouter, :one_signal_one_observer
  alias __MODULE__.{CreateProductService, IncreaseStockService}

  defdelegate create_product, to: CreateProductService, as: :call
  defdelegate increase_stock(product_id, amount \\ 1), to: IncreaseStockService, as: :call
end
