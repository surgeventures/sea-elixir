# Building signals

As established, `Sea.Signal.emit/1` takes your signal struct and emits it to defined observers.

    %InvoiceCreatedSignal{invoice_number: "2019/1"}
    |> Sea.Signal.emit()

In practice, you'll often want to convert more complex data structures into signal payload. In such
cases, the signal module serves as a fitting place for placing such conversion. Let's place it in
`build` function like below:

    defmodule InvoiceCreatedSignal do
      use Sea.Signal

      emit_to AnalyticsObserver

      defstruct [:invoice_number]

      def build(%Invoice{invoice_number: invoice_number}) do
        %__MODULE__{
          invoice_number: invoice_number
        }
      end
    end

And so you would emit the signal as follows:

    invoice
    |> InvoiceCreatedSignal.build()
    |> Sea.Signal.emit()

Now however, assuming that the function which builds the signal struct from arbitrary data is indeed
named `build` (ie. it implements the `c:Sea.Signal.build/1` callback), you may simplify the signal
build-and-emission code to just a single function call:

    InvoiceCreatedSignal.emit(invoice)

It may look like one line less, but single signal may be emitted from multiple places & multiple
input data structures in more complex applications plus the point of abstracting away side-effects
was to make things clearer so the `c:Sea.Signal.emit/1` convenience may make a significant
difference.
