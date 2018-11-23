defmodule InvoicingApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :invoicing_app,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {InvoicingApp.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:sea, path: "../.."},
      {:uuid, "~> 1.1"}
    ]
  end
end
