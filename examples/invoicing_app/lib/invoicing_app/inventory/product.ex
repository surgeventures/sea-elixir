defmodule InvoicingApp.Inventory.Product do
  @moduledoc false

  use Ecto.Schema

  schema "inventory_products" do
    field(:stock, :integer, default: 0)

    timestamps()
  end
end
