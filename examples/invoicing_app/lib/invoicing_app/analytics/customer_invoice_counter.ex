defmodule InvoicingApp.Analytics.CustomerInvoiceCounter do
  @moduledoc false

  use Ecto.Schema

  schema "analytics_customer_invoice_counters" do
    field(:customer_id, :integer)
    field(:invoice_count, :integer, default: 0)
  end
end
