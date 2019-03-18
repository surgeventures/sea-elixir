defmodule Sea.Observer do
  @moduledoc """
  Defines observer capable of handling signals that will get emitted to it.
  """

  @doc """
  Handle emitted signal.

  ## Example

      def handle_signal(%UserRegisteredSignal{user_id: _user_id}) do
        IncrementUserCount.call()
      end
  """
  @callback handle_signal(struct()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end
end
