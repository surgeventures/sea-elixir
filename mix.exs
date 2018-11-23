defmodule Sea.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :sea,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),

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
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: [:dev]}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

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
      extras: ["README.md"]
    ]
  end
end
