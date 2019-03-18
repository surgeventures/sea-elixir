# Sea for Elixir

[![Hex version badge](https://img.shields.io/hexpm/v/sea.svg)](https://hex.pm/packages/sea)
[![License badge](https://img.shields.io/hexpm/l/sea.svg)](https://github.com/surgeventures/sea-elixir/blob/master/LICENSE.md)
[![Build status badge](https://img.shields.io/circleci/project/github/surgeventures/sea-elixir/master.svg)](https://circleci.com/gh/surgeventures/sea-elixir/tree/master)
[![Code coverage badge](https://img.shields.io/codecov/c/github/surgeventures/sea-elixir/master.svg)](https://codecov.io/gh/surgeventures/sea-elixir/branch/master)

Sea facilitates and abstracts away side-effects - an important aspect of your Elixir applications
that often gets lost between the lines. It does so in a way loosely inspired by the observer pattern
ie. by making the source event (here, represented by signal) aware of its listeners (here,
represented by observers).

This design choice, as opposed eg. to pubsub where producer is made unaware of consumers,
intentionally couples the signal with its observers in order to simplify the reasoning about
synchronous operations within single system. It was introduced as an optimal abstraction for
facilitating side-effect-like interactions between relatively uncoupled modules (or "contexts" if
you will) that interact with each other in synchronous way within single coherent system.

## Installation

Add `sea` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sea, "~> 0.2.0"}
  ]
end
```

You may pick the newest version number from [Hex](https://hex.pm/packages/sea).

## Usage

Complete documentation for `Sea` module, along with comprehensive guides that'll lead you through
concepts behind Sea, can be found on [HexDocs](https://hexdocs.pm/sea).

- [Basic example]
- [Building signals]
- [Organizing observers]
- [Decoupling contexts]
- [Testing]
- [API reference]

In addition to docs, you may also be interested in the [invoicing_app] sample application that
implements a simple DDD project. There, Sea plays a key role in decoupling contexts that interact
with each other within a single database transaction.

## Motivation

Sea is a pattern library. As such it's really thin and technically unsophisticated (although it does
take care of some little details so you don't have to). But the real benefits come from the pattern
itself and its impact on your codebase.

* **expressiveness** - side-effects triggered via signals are easy to track and maintain in the
  growing codebase with growing number of interacting business contexts

* **transactional safety** - side-effects synchronously triggered inside database transactions
  get committed or rolled back together with the original change that caused them

* **uniformity** - signals & observers scattered across modules may follow a consistent naming
  convention to make their code more compact and the project structure more obvious

* **traceability** - by making signals aware of interested parties (observers) and emitting to
  them in defined order it's easy to trace the whole flow with side-effects

* **loose coupling** - signals facilitate construction of event payload that may (should) include
  uncoupled primitive types instead of structures and behaviors tied to specific domain

* **encapsulation** - as opposed to inline calls, side-effect logic implemented in observers
  reduces the external APIs that would otherwise be required to make the side-effect happen

* **self-documentation** - side-effects put in dedicated entity (signals) introduce a facility for
  documenting and expressing payload of domain events across the system

* **test isolation** - side-effects triggered via signals instead of via inline calls may be
  easily mocked away in order for signal origin to be tested without caring about them

* **sync & async unification** - plug async eventing solution as one of synchronous transactional
  side-effects to achieve reliable sync and async flows with single eventing syntax

[Basic example]: https://hexdocs.pm/sea/basic_example.html
[Building signals]: https://hexdocs.pm/sea/building_signals.html
[Organizing observers]: https://hexdocs.pm/sea/organizing_observers.html
[Decoupling contexts]: https://hexdocs.pm/sea/decoupling_contexts.html
[Testing]: https://hexdocs.pm/sea/testing.html
[API reference]: https://hexdocs.pm/sea/api-reference.html
[invoicing_app]: https://github.com/surgeventures/sea-elixir/tree/master/examples/invoicing_app
