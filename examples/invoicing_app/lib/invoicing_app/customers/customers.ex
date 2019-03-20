defmodule InvoicingApp.Customers do
  @moduledoc """
  Customers system manages customers interested in purchasing products.
  """

  use InvoicingApp.SignalRouter, :one_signal_one_observer
  alias __MODULE__.{CheckActiveService, RegisterAccountService}

  defdelegate active?(account_id), to: CheckActiveService, as: :call
  defdelegate register_account(name), to: RegisterAccountService, as: :call
end
