use Mix.Config

if Mix.env() == :test do
  config :junit_formatter, report_dir: "/tmp/sea-elixir-test-results/exunit"
end
