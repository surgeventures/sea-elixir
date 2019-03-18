# Basic example

In Sea, you define signal and a bunch of observers that get called upon signal emission:

    defmodule InvoiceCreatedSignal do
      use Sea.Signal

      emit_to AnalyticsObserver

      defstruct [:invoice_number]
    end

    defmodule AnalyticsObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%InvoiceCreatedSignal{invoice_number: invoice_number}) do
        IO.puts("Adding invoice #{invoice_number} to analytics accumulators")
      end
    end

    %InvoiceCreatedSignal{invoice_number: "2019/1"}
    |> Sea.Signal.emit()

At its core, `Sea.Signal.emit/1` takes your signal struct and emits it to defined observers by
calling `c:Sea.Observer.handle_signal/1` in each of them with the specific signal payload. Observer
calls are made synchronously (which makes the operations belong to the same process and same
database transaction) and in order (which makes it easy to reason about the whole flow and to debug
it if needed).

You wouldn't be far from truth by saying that Sea is just a single `Enum.each/2` loop (and it can
actually be found in `Sea.Signal.emit/1` code) with a contract and fancy philosophy around it.
