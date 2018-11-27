if Code.ensure_loaded?(Mox) do
  defmodule Sea.SignalMocking do
    @moduledoc """
    Provides helpers for mocking signals with the Mox library.
    """

    @doc """
    Defines mock on specific signal module for testing purposes.
    """
    def defsignalmock(signal_mod) do
      Mox.defmock(
        :"#{signal_mod}.Mock",
        for: :"#{signal_mod}.Behaviour"
      )
    end

    @doc """
    Passes through actual signal implementation so that side-effects would get called.
    """
    def enable_signal(signal_mod) do
      Mox.stub_with(:"#{signal_mod}.Mock", signal_mod)
    end

    @doc """
    Stubs specific signal with noop so that side-effects wouldn't get called.
    """
    def disable_signal(signal_mod) do
      Mox.stub(:"#{signal_mod}.Mock", :emit, fn _ -> :ok end)
    end
  end
end
