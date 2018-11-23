defmodule InvoicingApp.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias InvoicingApp.Repo

  using do
    quote do
      alias InvoicingApp.Repo

      import Ecto
      import Ecto.{Changeset, Query}
      import InvoicingApp.DataCase
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
