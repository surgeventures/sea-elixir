# Organizing observers

You can organize your signals and observers in any way you like and link them freely with
`Sea.Signal.emit_to/1` macro calls.

For instance, you could choose to share observer logic for handling multiple signals by implementing
single observer module with multiple `c:Sea.Observer.handle_signal/1` clauses, target it from multiple
signals and pattern-match specific signal or group of signals there. The `AnalyticsObserver` from
the [basic example] could become such multi-signal observer, ie:

    defmodule AnalyticsObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%InvoiceCreatedSignal{invoice_number: invoice_number}) do
        IO.puts("Adding invoice #{invoice_number} to analytics accumulators")
        increase_count(:invoice)
      end

      @impl true
      def handle_signal(%UserRegisteredSignal{email: email}) do
        IO.puts("Adding user #{email} to analytics accumulators")
        increase_count(:user)
      end

      defp increase_count(type) do
        # common logic here
      end
    end

In a more complex application with multiple contexts you may choose to map signal and observer names
across context modules in order to simplify working with a growing number of signals and their
observers scattered across project modules. This may be simplified and made consistent by using the
`Sea.Signal.emit_within/1` macro:

    defmodule InvoicingApp.Sales.InvoiceCreatedSignal do
      use Sea.Signal

      emit_within InvoicingApp.{Analytics, Customers}
      # ...is equivalent to more explicit:
      # emit_to InvoicingApp.Analytics.InvoiceCreatedObserver
      # emit_to InvoicingApp.Customers.InvoiceCreatedObserver

      defstruct [:invoice_number, customer_id]
    end

In such case, Sea will take the original signal name and replace the `Signal` suffix with `Observer`
suffix to infer the name of observer module within specific parent (context) module. This should
keep the entire codebase that sticks to `emit_within` consistent and predictable.

[Basic example]: basic_example.html
