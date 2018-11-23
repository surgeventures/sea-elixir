defmodule InvoicingApp.Analytics do
  @moduledoc """
  Analytics system manages data warehousing, bookkeeping and reporting.
  """

  alias __MODULE__.GetInvoiceCountService

  def get_invoice_count(customer_id) do
    GetInvoiceCountService.call(customer_id)
  end
end
