# Invoicing app

Sample invoicing application for showcasing the Sea package. It includes:

- a complete signal-observer library flow that starts in [create_invoice_service.ex] and makes use
  of [signal] with a bunch of observers ([one of observers]) within real database transaction flow
  backed by Ecto

- a complete test suite that covers that flow including [unit tests], [integration tests], [mock
  definitions] and [mock-aware project configuration]

[create_invoice_service.ex]: lib/invoicing_app/sales/create_invoice_service.ex
[signal]: lib/invoicing_app/sales/invoice_created_signal.ex
[one of observers]: lib/invoicing_app/analytics/invoice_created_observer.ex
[unit tests]: test/unit
[integration tests]: test/integration
[mock definitions]: test/support/mocks.ex
[mock-aware project configuration]: config/config.exs
