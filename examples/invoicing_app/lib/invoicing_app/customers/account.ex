defmodule InvoicingApp.Customers.Account do
  @moduledoc false

  use Ecto.Schema

  schema "customers_accounts" do
    field(:name, :string)
    field(:active, :boolean, default: false)

    timestamps()
  end
end
