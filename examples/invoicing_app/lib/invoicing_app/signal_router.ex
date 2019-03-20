defmodule InvoicingApp.SignalRouter do
  @moduledoc """
  Defines project-wide convention for routing Sea signals to nested observers.

  This module is completely optional but serves as a working example as to how to route signals sent
  to root-level module deeper into observers within it. This way we can write `emit_to
  InvoicingApp.Inventory` instead of `emit_to InvoicingApp.Inventory.InvoiceCreatedObserver` which
  yields benefits described in the *Organizing observers* guide.
  """

  @doc """
  Routes incoming signals to nested observer (single one for all incoming signals).
  """
  def single_observer do
    quote do
      use Sea.Observer

      @impl true
      def handle_signal(signal) do
        __MODULE__.Observer.handle_signal(signal)
      end
    end
  end

  @doc """
  Routes incoming signals to nested observers (separate ones for each incoming signal).
  """
  def one_signal_one_observer do
    quote do
      use Sea.Observer

      @impl true
      def handle_signal(signal = %{__struct__: signal_mod}) do
        signal_name = signal_mod |> Module.split() |> List.last()
        observer_name = String.replace(signal_name, ~r/Signal$/, "Observer")
        observer_mod = :"#{__MODULE__}.#{observer_name}"

        observer_mod.handle_signal(signal)
      end
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
