defmodule InvoicingApp.Analytics.GetInvoiceCountService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Analytics.CustomerInvoiceCounter

  def call(customer_id) do
    counter = Repo.get!(CustomerInvoiceCounter, customer_id)
    counter.invoice_count
  end
end
