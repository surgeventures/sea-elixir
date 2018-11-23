defmodule InvoicingApp.Analytics.GetInvoiceCountService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Analytics.CustomerInvoiceCounter

  def call(customer_id) do
    counter = Repo.get_by(CustomerInvoiceCounter, customer_id: customer_id)

    if counter do
      counter.invoice_count
    else
      0
    end
  end
end
