# Sea for Elixir

[![Build status badge](https://img.shields.io/circleci/project/github/surgeventures/sea-elixir/master.svg)](https://circleci.com/gh/surgeventures/sea-elixir/tree/master)
[![Code coverage badge](https://img.shields.io/codecov/c/github/surgeventures/sea-elixir/master.svg)](https://codecov.io/gh/surgeventures/sea-elixir/branch/master)

Side-effect abstraction for Elixir - signal and observe your side-effects like a pro.

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

## Installation

Add `sea` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sea, "~> x.y"}
  ]
end
```

You may pick the newest version number from [Hex](https://hex.pm/packages/sea).

As the package strictly follows [semantic versioning](https://semver.org), you may specify the
version as `~> x.y` so that you're up-to-date with minor & patch releases and stay away from
breaking changes.

## Usage

The docs for `Sea` module, along with complete usage examples, can be found on
[HexDocs](https://hexdocs.pm/sea).
