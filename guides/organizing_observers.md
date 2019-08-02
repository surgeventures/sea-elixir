# Organizing observers

You can organize your signals and observers in any way you like and link them freely with
`Sea.Signal.emit_to/1` macro calls. Sea doesn't limit you in this regard as it'll depend on specific
use cases how best to name and split observers mapped to the signals. In this guide, we'll review
some of possible approaches and propose technical solutions for applying them efficiently.

For instance, you could choose to share observer logic for handling multiple signals by implementing
single observer module with multiple `c:Sea.Observer.handle_signal/1` clauses, target it from
multiple signals and pattern-match specific signal or group of signals there. The
`AnalyticsObserver` from the [getting started guide] could become such multi-signal observer, ie:

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

This approach was applied in exemplary [`InvoicingApp.Analytics.Observer`] module.

An opposite approach would be to implement observers dedicated to specific signals and perhaps map
signal and observer names across context modules in order to simplify working with a growing number
of signals and observers scattered across project modules, ie:

    defmodule InvocingApp.Sales.InvoiceCreatedSignal do
      use Sea.Signal

      emit_to InvocingApp.Customers.InvoiceCreatedObserver
      emit_to InvocingApp.Inventory.InvoiceCreatedObserver

      # ...
    end

    defmodule InvocingApp.Customers.InvoiceCreatedObserver do
      use Sea.Observer

      # ...
    end

    defmodule InvocingApp.Inventory.InvoiceCreatedObserver do
      use Sea.Observer

      # ...
    end

This is indeed how exemplary [`InvoicingApp.Customers.InvoiceCreatedObserver`] and
[`InvoicingApp.Inventory.InvoiceCreatedObserver`] were organized.

Regardless of the approach, you may want to avoid a fishy practice from the above example - forcing
signals nested in `InvoicingApp.Sales` module to pick specific observer modules internal to
`InvoicingApp.Customers` or `InvoicingApp.Inventory` - they should be a private implementation
detail of these modules. This can be achieved by delegating `handle_signal` from entry module to one
of its nested observers. For the "single observer" approach, this could be as simple as:

    def InvoicingApp.Analytics do
      use Sea.Observer

      defdelegate handle_signal(signal), to: __MODULE__.Observer
    end

For "one signal one observer" approach we could pick observer dynamically based on signal name:

    def InvoicingApp.Customers do
      use Sea.Observer

      @impl true
      def handle_signal(signal = %{__struct__: signal_mod}) do
        signal_name = signal_mod |> Module.split() |> List.last()
        observer_name = String.replace(signal_name, ~r/Signal$/, "Observer")
        observer_mod = :"#{__MODULE__}.#{observer_name}"

        observer_mod.handle_signal(signal)
      end
    end

Here, the original signal name was taken and the `Signal` suffix was replaced with `Observer` suffix
in order to infer the name of child observer module within specific entry module.

Finally, you could put one (or both) of these observer organization strategies into reusable module
that you would subsequently `use` in all entry modules that include observers. A basic version of
such router that covers routing strategies described above is available in `Sea.SignalRouter`
module. You can easily create your own as well.

This way all of your observers will be organized in consistent and predictable way, with a single
module that describes the rules governing this aspect of your application and with explicit yet
compact references to it all over the project.

[getting started guide]: getting_started.html
[`InvoicingApp.Analytics.Observer`]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/lib/invoicing_app/analytics/observer.ex
[`InvoicingApp.Customers.InvoiceCreatedObserver`]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/lib/invoicing_app/customers/invoice_created_observer.ex
[`InvoicingApp.Inventory.InvoiceCreatedObserver`]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/lib/invoicing_app/inventory/invoice_created_observer.ex
