defmodule InvoicingApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :invoicing_app,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {InvoicingApp.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:mox, "~> 0.4", only: :test},
      {:postgrex, "~> 0.14"},
      {:sea, path: "../.."},
      {:uuid, "~> 1.1"}
    ]
  end
end
