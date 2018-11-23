defmodule InvoicingApp.Customers.CheckActiveService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Customers.Account

  def call(account_id) do
    account = Repo.get!(Account, account_id)
    account.active
  end
end
