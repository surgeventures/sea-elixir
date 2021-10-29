defmodule Sea.MixProject do
  use Mix.Project

  @version "0.5.0"

  def project do
    [
      app: :sea,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),

      # Hex
      description: "Side-effect abstraction - signal and observe your side-effects like a pro",
      package: package(),

      # Docs
      name: "Sea",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: extra_applications(Mix.env())
    ]
  end

  def extra_applications(:test), do: [:mox]
  def extra_applications(_), do: []

  defp deps do
    [
      {:credo, "~> 0.10", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, "~> 3.0", only: :test},
      {:mox, "~> 1.0", optional: true}
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  defp package do
    [
      maintainers: ["Karol Słuszniak"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/surgeventures/sea-elixir",
        "Shedul" => "https://www.shedul.com"
      },
      files: ~w(.formatter.exs mix.exs LICENSE.md README.md CHANGELOG.md lib)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/sea",
      source_url: "https://github.com/surgeventures/sea-elixir",
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "README.md",
      "CHANGELOG.md",
      "guides/getting_started.md",
      "guides/building_signals.md",
      "guides/organizing_observers.md",
      "guides/decoupling_contexts.md",
      "guides/defining_side_effects_responsibly.md",
      "guides/composing_transactions.md",
      "guides/testing.md"
    ]
  end

  defp groups_for_extras do
    [
      Guides: ~r/guides\/[^\/]+\.md/
    ]
  end
end
