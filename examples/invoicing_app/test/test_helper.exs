Mix.EctoSQL.ensure_started(InvoicingApp.Repo, [])
{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
