# Testing

With Sea acting as your hub for distributing side-effects across modules you may have two main
testing scenarios involving signals:

1. **Signals disabled** for unit testing purposes. In such scenario you want your signal emission
   stubbed away from the logic of unit that normally does emit it. In some of those cases, you would
   still like to verify that the signal does get emitted without causing side-effects.

2. **Signals enabled** for testing integration between contexts. In such scenario you want your
   signal to behave like it does in final product - to trigger observers all over the place and
   cause all the side-effects so you can check if they behave properly in integration.

Ideally, you'd like these two kinds of tests to execute asynchronously. And perhaps you'd like to do
some other custom mocking or stubbing on top of the signals.

Picking up on the previous example, you could want to ensure that `CreateInvoiceService` can be
tested in isolation from side-effects in `Analytics`, `Customers` and `Inventory` contexts, but at
the same time to also create an integration test which does opt-in for the side-effects.

## Signal mocking with Mox

Sea covers all of these cases by leveraging the excellent `Mox` library to define mocks on top of
signals. It also provides `Sea.SignalMocking` module with helpers useful to minimize the boilerplate
around testing and mocking signals.

In order to mock signals, go through the following procedure:

1. Add `Mox` to the project.
2. Add config that by default points to `SomeSignal`, but to `SomeSignal.Mock` in test env.
3. Call the signal module fetched from config instead of `SomeSignal` in your app code.
4. Define mock by calling `Sea.SignalMocking.defsignalmock/1` in test helper or support script.
5. Call `Sea.SignalMocking.enable_signal/1` or `Sea.SignalMocking.disable_signal/1`in test cases.

By leveraging Mox, Sea gives you all the options for testing and verifying mocks that Mox does. In
order to do so, assume the following module naming convention:

- `SomeSignal` is your actual signal implementation
- `SomeSignal.Mock` is the mocked version of it
- `SomeSignal.Behaviour` is the behaviour implemented by both of the above

This means that you may do the following in your test case in order to ensure that `SomeSignal` does
get called with specific input without it causing side-effects:

    disable_signal(SomeSignal)
    expect(SomeSignal.Mock, :emit, fn %SomeInput{} -> :ok end)

    # ...
    # call & test the code which emits SomeSignal
    # ...

    verify!(SomeSignal.Mock)

## Working example

A complete end-to-end example on side-effect unit and integration testing may be found in
[invoicing_app] example. Specifically, test cases within [test/unit] and [test/integration]
directories depict both approaches described above.

[invoicing_app]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app
[test/unit]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/test/unit
[test/integration]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app/test/integration
