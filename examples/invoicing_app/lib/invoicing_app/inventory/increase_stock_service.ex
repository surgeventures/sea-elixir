defmodule InvoicingApp.Inventory.IncreaseStockService do
  import Ecto.Query
  alias InvoicingApp.Repo
  alias InvoicingApp.Inventory.Product

  def call(product_id, amount) do
    Repo.update_all(
      from(
        product in Product,
        where: product.id == ^product_id,
        update: [inc: [stock: ^amount]]
      ),
      []
    )
  end
end
