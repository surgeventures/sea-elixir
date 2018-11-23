defmodule InvoicingApp.Sales do
  @moduledoc """
  Sales system manages invoicing and misc sales operations.
  """

  alias __MODULE__.CreateInvoiceService

  def create_invoice(product_id, customer_id) do
    CreateInvoiceService.call(product_id, customer_id)
  end
end
