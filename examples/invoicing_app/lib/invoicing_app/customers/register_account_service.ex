defmodule InvoicingApp.Customers.RegisterAccountService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Customers.Account

  def call(name) do
    account = Repo.insert!(%Account{name: name})
    account.id
  end
end
