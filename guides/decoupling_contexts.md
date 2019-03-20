# Decoupling contexts

This guide is basically a walkthrough for the library part of the [invoicing_app]. You may want to
take a look at a complete application code in order to see the whole picture.

You start with a service that causes several side-effects across the system:

    defmodule InvoicingApp.Sales.CreateInvoiceService do
      alias InvoicingApp.Repo
      alias InvoicingApp.Sales.Invoice
      alias InvoicingApp.{Analytics, Customers, Inventory}

      def call(product_id, customer_id) do
        invoice_attrs = [
          product_id: product_id,
          customer_id: customer_id
        ]

        Repo.transaction(fn ->
          invoice =
            invoice_attrs
            |> Invoice.changeset()
            |> Repo.insert()

          Analytics.increase_invoice_count()
          Customers.mark_customer_active(customer_id)
          Inventory.decrease_stock(product_id)
        end)
      end
    end

As you can see, each external side-effect is directly invoked from the original service, which means
that:

- this code doesn't emphasize (doesn't signal) where's the point at which invoice is created
- it's hard to tell the logical boundary between this unit's logic and external side-effects
- side-effects are hard to mock away for unit testing purposes
- each side-effect must have relevant external (possibly redundant) API interface available
- it's tempting to pass rich and coupled data structures to those external APIs
- each additional side-effect will cause this unit's code to grow further

We'll fix these issues by abstracting away these side-effects.

Let's start by introducing a signal capable of building itself from our invoice struct:

    defmodule InvoicingApp.Sales.InvoiceCreatedSignal do
      use Sea.Signal

      emit_to InvoicingApp.{Analytics, Customers, Inventory}

      defstruct [:customer_id, :product_id]

      def build(%InvoicingApp.Sales.Invoice{customer_id: customer_id, product_id: product_id}) do
        %__MODULE__{
          customer_id: customer_id,
          product_id: product_id
        }
      end
    end

Now let's emit it from the service instead of calling all these external modules:

    defmodule InvoicingApp.Sales.CreateInvoiceService do
      alias InvoicingApp.Repo
      alias InvoicingApp.Sales.{Invoice, InvoiceCreatedSignal}

      def call(product_id, customer_id) do
        invoice_attrs = [
          product_id: product_id,
          customer_id: customer_id
        ]

        Repo.transaction(fn ->
          invoice =
            invoice_attrs
            |> Invoice.changeset()
            |> Repo.insert()

          InvoiceCreatedSignal.emit(invoice)
        end)
      end
    end

And finally, let's ensure that observers are in place to handle the external side-effects:

    defmodule InvoicingApp.Analytics.InvoiceCreatedObserver do
      use Sea.Observer

      def handle_signal(signal) do
        # ...
      end
    end

    defmodule InvoicingApp.Customers.InvoiceCreatedObserver do
      use Sea.Observer

      def handle_signal(signal) do
        # ...
      end
    end

    defmodule InvoicingApp.Inventory.InvoiceCreatedObserver do
      use Sea.Observer

      def handle_signal(signal) do
        # ...
      end
    end

That's it - the side-effect has been properly facilitated and all the perks presented in [motivation
section of the readme] are applied in full force.

[invoicing_app]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app
[motivation section of the readme]: readme.html#motivation
