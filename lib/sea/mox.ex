defmodule Sea.Mox do
  def defsignalmock(signal_mod) do
    Mox.defmock(
      :"#{signal_mod}.Mock",
      for: :"#{signal_mod}.Behaviour"
    )
  end

  def enable_signal(signal_mod) do
    Mox.stub_with(
      :"#{signal_mod}.Mock",
      signal_mod
    )
  end

  def disable_signal(signal_mod) do
    Mox.stub(:"#{signal_mod}.Mock", :emit, fn _ -> :ok end)
  end
end
