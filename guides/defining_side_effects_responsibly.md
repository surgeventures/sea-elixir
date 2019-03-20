# Defining side-effects responsibly

OK, so you've started moving your secondary logic away from originating services to Sea observers.
Nothing beats the slim service code, right? But should you move *all* of the logic besides bare
invoice row insertion in a service such as [`CreateInvoiceService`]? Certainly not, because then
your service code will cease to "tell the whole story". So how do you tell side-effects from core
service logic?

Above every technical detail and convenience brought by Sea, it provides a logical separation for
side-effects as a distinct part of your applications. As such, the judgement about differentiaing
core service logic from side-effects is not a technical one, but should rather be dictated by
logical/business/domain split of your application. And so your signals should be oriented around
business/domain events rather than technical indicators (such as eg. end of every database
transaction - which smells suspiciously similar to [model callbacks banished from Ecto]).

In a system with multiple loosely-coupled modules (or "contexts") it's those modules that are
responsible for drawing the boundaries between self-contained functional areas of the system. In
such case, it's the crossing of those boundaries that may indicate that you're no longer in the core
service area but in logical side-effect territory instead. Regardless of the code organization it
all comes down to what your service really does at its core (hopefully indicated by a descriptive
name) and what may/may not be a logically detachable consequence of its actions.

For example, of all the observers attached to exemplary [`InvoiceCreatedSignal`], one may easily be
considered a controversial one:

    defmodule InvoicingApp.Inventory.InvoiceCreatedObserver do
      use Sea.Observer

      # ...

      def handle_signal(%InvoiceCreatedSignal{product_id: product_id}) do
        IncreaseStockService.call(product_id, -1)
      end
    end

This particular side-effect of invoice creation - the decrease of stock level of purchased item -
may easily be considered as such a core part of invoice creation logic that - even if it belongs to
separate module as per functional split - it may be better off called directly from the service,
like below:

    defmodule InvoicingApp.Sales.CreateInvoiceService do
      # ...

      def call(product_id, customer_id) do
        Repo.transaction(fn ->
          invoice =
            invoice_attrs
            |> Invoice.changeset()
            |> Repo.insert!()

          adjust_purchased_product_stock(invoice)

          InvoiceCreatedSignal.emit(invoice)

          invoice
        end)
        |> elem(1)
      end

      defp adjust_purchased_product_stock(invoice) do
        Inventory.increase_stock(invoice.product_id)
      end
    end

Unit testing may provide a good hint here. If it doesn't ever make sense to test specific service
unit without particular "side-effect" then perhaps it's not a side-effect after all. And indeed,
that's the case of [`CreateInvoiceServiceTest`] test which deeply cares about the
`stock_cannot_be_negative` constraint.

[model callbacks banished from Ecto]: http://blog.plataformatec.com.br/2015/12/ecto-v1-1-released-and-ecto-v2-0-plans
[`CreateInvoiceService`]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/lib/invoicing_app/sales/create_invoice_service.ex
[`InvoiceCreatedSignal`]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/lib/invoicing_app/sales/invoice_created_signal.ex
[`CreateInvoiceServiceTest`]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/test/unit/invoicing_app/sales/create_invoice_service_test.exs
