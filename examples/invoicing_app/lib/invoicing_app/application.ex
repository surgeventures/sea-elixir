defmodule InvoicingApp.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {InvoicingApp.Repo, []}
    ]

    opts = [strategy: :one_for_one, name: Asd.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
