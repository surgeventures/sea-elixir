defmodule Sea do
  @moduledoc ~S"""
  Side-effect abstraction - put your synchronous side-effects in order.

  Sea consists of following modules:

  - `Sea.Signal` - defines signal that will get emitted to defined observers
  - `Sea.Observer` - Defines observer capable of handling signals emitted to it

  ## Usage

  ### Basic example

  In Sea, you define signal and a bunch of observers that get called upon signal emission:

      defmodule SomeSignal do
        use Sea.Signal

        emits_to SomeObserver

        defstruct [:some_data]
      end

      defmodule SomeObserver do
        use Sea.Observer

        @impl true
        def handle_signal(%SomeSignal{some_data: some_data}) do
          IO.puts("Acting upon some signal with data: #{inspect(some_data)}")
        end
      end

      SomeSignal.emit(%SomeSignal{some_data: "foo"})

  ### Signal-Observer naming convention

  In order to simplify working with growing number of signals and their observers scattered across
  project modules, you may define observers like this:

      defmodule MyApp.X.SomeSignal do
        use Sea.Signal

        emits_into MyApp.{Y, Z}

        defstruct [:some_data]
      end

      defmodule MyApp.Y.SomeObserver do
        use Sea.Observer

        @impl true
        def handle_signal(%MyApp.X.SomeSignal{some_data: some_data}) do
          IO.puts("Y acting upon some signal with data: #{inspect(some_data)}")
        end
      end

      defmodule MyApp.Z.SomeObserver do
        use Sea.Observer

        @impl true
        def handle_signal(%MyApp.X.SomeSignal{some_data: some_data}) do
          IO.puts("Z acting upon some signal with data: #{inspect(some_data)}")
        end
      end

      Sea.Signal.emit(%MyApp.X.SomeSignal{some_data: "foo"})

  ### Decoupling contexts

  Let's assume you have a service that causes several side-effects across the system:

      defmodule MyApp.Sales.CreateInvoiceService do
        alias MyApp.Repo
        alias MyApp.Sales.Invoice
        alias MyApp.{Analytics, Customers, Inventory}

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

  As you can see, each external side-effect is directly invoked from the original service. This code
  is a great case to introduce the benefits of Sea.

  Let's start by introducing a signal capable of building itself from our invoice struct:

      defmodule MyApp.Sales.InvoiceCreatedSignal do
        use Sea.Signal

        emits_into MyApp.{Analytics, Customers, Inventory}

        defstruct [:customer_id, :product_id]

        def build(%MyApp.Sales.Invoice{customer_id: customer_id, product_id: product_id}) do
          %__MODULE__{
            customer_id: customer_id,
            product_id: product_id
          }
        end
      end

  Now let's call it from the service instead of calling all these external modules:

      defmodule MyApp.Sales.CreateInvoiceService do
        alias MyApp.Repo
        alias MyApp.Sales.{Invoice, InvoiceCreatedSignal}

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

      defmodule MyApp.Analytics.InvoiceCreatedObserver do
        use Sea.Observer

        def handle_signal(signal) do
          # ...
        end
      end

      defmodule MyApp.Customers.InvoiceCreatedObserver do
        use Sea.Observer

        def handle_signal(signal) do
          # ...
        end
      end

      defmodule MyApp.Inventory.InvoiceCreatedObserver do
        use Sea.Observer

        def handle_signal(signal) do
          # ...
        end
      end

  That's it - the side-effect has been properly facilitated.

  """
end
