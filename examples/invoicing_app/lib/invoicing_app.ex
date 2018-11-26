defmodule InvoicingApp do
  @moduledoc """
  Sample invoicing application for showcasing the Sea package.
  """

  @doc false
  def get_mod_config_key(mod, key, default \\ nil) do
    mod_config = Application.get_env(:invoicing_app, mod, [])
    Keyword.get(mod_config, key, default)
  end
end
