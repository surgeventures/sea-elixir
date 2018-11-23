defmodule InvoicingApp.Customers do
  @moduledoc """
  Customers system manages customers interested in purchasing products.
  """

  alias __MODULE__.{
    CheckActiveService,
    RegisterAccountService
  }

  def active?(account_id) do
    CheckActiveService.call(account_id)
  end

  def register_account(name) do
    RegisterAccountService.call(name)
  end
end
