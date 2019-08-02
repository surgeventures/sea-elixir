defmodule Sea.SignalRouter do
  @moduledoc """
  Defines project-wide convention for routing Sea signals to nested observers.

  ## Usage

  For single observer:

      defmodule MyApp.Sales.InvoiceCreatedSignal do
        use Sea.Signal

        emit_to MyApp.Inventory

        # ...
      end

      defmodule MyApp.Inventory do
        use Sea.SignalRouter, :single_observer

        # ...
      end

      defmodule MyApp.Inventory.Observer do
        use Sea.Observer

        # example of catching multiple signals to trigger the same operation
        def handle_signal(signal = %{__struct__: struct}) when struct in [
          MyApp.Sales.InvoiceCreatedSignal
        ] do
          MyApp.Inventory.UpdateStatsService.call()
        end
      end

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
      def handle_signal(%{__struct__: signal_mod} = signal) do
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
