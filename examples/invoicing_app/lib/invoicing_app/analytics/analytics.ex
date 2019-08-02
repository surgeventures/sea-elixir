defmodule InvoicingApp.Analytics do
  @moduledoc """
  Analytics system manages data warehousing, bookkeeping and reporting.
  """

  use Sea.SignalRouter, :single_observer
  alias __MODULE__.GetInvoiceCountService

  defdelegate get_invoice_count(customer_id), to: GetInvoiceCountService, as: :call
end
