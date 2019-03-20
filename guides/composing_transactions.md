# Composing transactions

As established, Sea calls observers synchronously upon signal emission. You can build on top of that
to wrap business operations and their side-effects into single database transaction, gaining all the
ACID guarantees for complex, cross-context flows. Among others, you gain a critical assurance that
all database changes introduced with the entire flow will be treated as a single atomic unit that
either succeeds or fails as an undividable whole. This vastly simplifies the flow control and error
handling of complex operation chains, including Sea-controlled side-effects. Traditionally it comes
at the expense of some database-relevant constraints, such as below:

1. Changes must happen within single database.

2. Changes must be wrappable in a single database transaction, ie. they must be made synchronously
   and through single connection from single client.

This is how the flow in [invoicing_app] was implemented - side-effect is emitted within transaction:

    defmodule InvoicingApp.Sales.CreateInvoiceService do
      # ...

      def call(product_id, customer_id) do
        # ...

        Repo.transaction(fn ->
          invoice =
            invoice_attrs
            |> Invoice.changeset()
            |> Repo.insert()

          InvoiceCreatedSignal.emit(invoice)
        end)
      end
    end

And so each side-effect, such as the counter increment below, belongs to that transaction:

    defmodule InvoicingApp.Analytics.InvoiceCreatedObserver do
      use Sea.Observer

      # ...

      def handle_signal(%InvoiceCreatedSignal{customer_id: customer_id}) do
        Repo.insert!(
          %CustomerInvoiceCounter{customer_id: customer_id, invoice_count: 1},
          conflict_target: :customer_id,
          on_conflict: [inc: [invoice_count: 1]]
        )
      end
    end

You'll want to stick to this convenient paradigm in order to make your life easier - unless you have
crazy solid reasons to leave it.

## External side-effects

So what if you do need to cause side-effects like:

- make changes in multiple databases (eg. belonging to external systems or standalone services)
- call external world-changing APIs
- produce asynchronous events delivered via some fancy message broker

You may or may not need the ACID safety in such cases but - depending on a case - the atomicity
guarantee or a weaker at-least-once/at-most-once guarantee will still be desired for side-effect
execution.

The good news is that you can still plug an observer that executes the asynchronous operation and
using Sea will still be beneficial to facilitate, emphasize and organize side-effects as a distinct
logical parts of your application. Benefits such as self-documentation and configurable test
isolation will still be there 'n shining. Plus the fact that some of your side-effects are
asynchronous but others are synchronous will be nicely abstracted away from original logic and
become a per-case observer concern.

If, in specific case, you can afford not to roll back an already triggered external change, you can
just stick to plain Sea side-effect. Let's consider the following example:

    defmodule InvoicingApp.ExternalAnalytics.Observer do
      use Sea.Observer

      # ...

      def handle_signal(%InvoiceCreatedSignal{customer_id: customer_id}) do
        ExternalAnalyticsServiceAPI.trigger_update("customer_invoices", customer_id: customer_id)
      end
    end

Being directly implemented in Sea observer, this external API call may execute within transaction
that ultimately fails. In such case, external service will still be asked to update specified data
aggregate, but it may be a pragmatic choice to let that happen as there's no great harm.

However, more often than not - especially if you depend on database constraints & checks that may
rollback transactions on regular basis - you won't be able to make such a shortcut. All these other
cases fall into the dreadful distributed transaction territory. The bad news is that Sea won't
automagically orchestrate operations that break the boundary of a single database transaction for
you. But this is really a good news too, because you get to pick any of dedicated solutions for
running distributed transactions, appropriate for the problem and the level of guarantees that you
require for specific task.

If your application still mostly depends on database transactions, you can easily isolate handling
of these unusual cases from regular flows by producing an artifact within the database (which means
it's still a subject to ACID) and then asynchronously converting it to external world change via
two-phase commit, saga or any other mechanism in properly isolated worker process responsible for
this non-trivial concern.

For example, you may want to push your signals through event bus. You could start with generic
observer like the following:

    defmodule InvoicingApp.EventBus.Observer do
      use Sea.Observer

      # ...

      def handle_signal(signal) do
        Repo.insert!(
          %Event{
            event_type: inspect(signal.__struct__),
            payload: Map.from_struct(signal),
          }
        )
      end
    end

And complete the producing end of your solution with following worker process:

    defmodule InvoicingApp.EventBus.Producer do
      use GenServer

      # ...

      # producer process calls this function in intervals
      def push_new_events_via_channel(chan) do
        Repo.transaction(fn ->
          # get new events pending publication to external broker
          new_events = Repo.all(from e in Event, lock: "FOR UPDATE")

          # publish in a batch with success confirmation from the broker
          Enum.each(new_events, fn event ->
            payload = Jason.encode!(event.payload)
            metadata = get_event_metadata(event)
            :ok = AMQP.Basic.publish(chan, "event_bus", "", payload, metadata)
          end)
          AMQP.Confirm.wait_for_confirms_or_die(chan)

          # remove events from the queue
          published_event_ids = Enum.map(new_events, & &1.id)
          Repo.delete_all(from e in Event, where: e.id in ^published_event_ids)
        end)
      end

      defp get_event_metadata(event) do
        [
          mandatory: true,
          persistent: true,
          content_type: "application/json",
          message_id: event.id,
          timestamp: DateTime.to_unix(event.inserted_at),
          type: event.event_type
        ]
      end
    end

This simplistic implementation aims at the at-least-once delivery guarantee (as in rare cases the
same database row may be pushed more than once), which may be enough for this particular event bus.

In the end, all the world changes in your side-effects will fall into one of three categories:

- internal database changes with ACID guarantees
- external changes made eagerly that are OK to get triggered in failed transaction
- database artifact producers for sake of delegating actual external changes elsewhere

[invoicing_app]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app
