defmodule InvoicingApp.Sales.Invoice do
  @moduledoc false

  use Ecto.Schema

  schema "sales_invoices" do
    field(:number, :string)
    field(:product_id, :integer)
    field(:customer_id, :integer)

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{
      product_id: Keyword.fetch!(params, :product_id),
      customer_id: Keyword.fetch!(params, :customer_id),
      number: UUID.uuid4()
    }
  end
end
