defmodule InvoicingApp.Customers.RegisterAccountService do
  alias InvoicingApp.Repo
  alias InvoicingApp.Customers.Account

  def call(name) do
    Repo.insert!(%Account{name: name})
  end
end
