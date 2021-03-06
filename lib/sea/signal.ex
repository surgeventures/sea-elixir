defmodule Sea.Signal do
  @moduledoc """
  Defines signal (aka. event) with payload that will get emitted to defined observers.
  """

  @doc """
  Build the signal struct from arbitrary input (or return it if already a signal struct).

  Sea provides the default implementation that will simply return the signal struct if it's provided
  as argument. Specific signal module may define further variants of `build` capable of taking any
  input and converting it to signal payload.
  """
  @callback build(any()) :: struct()

  @doc """
  Emit the signal from arbitrary input (converted to signal struct if necessary).

  Sea provides its implementation of `emit` that will call `build` with whatever is passed to it in
  order to normalize the input into the signal struct and then it'll call `Sea.Signal.emit/1` with
  that in order to actually call defined observers.
  """
  @callback emit(any()) :: :ok

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: :macros

      defmodule Behaviour do
        @moduledoc false

        @callback build(any()) :: struct()
        @callback emit(any()) :: :ok
      end

      @behaviour __MODULE__.Behaviour

      Module.register_attribute(__MODULE__, :observers_rev, accumulate: true)

      @before_compile unquote(__MODULE__)
      @after_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @observers Enum.reverse(@observers_rev)

      @doc false
      def __observers__ do
        @observers
      end

      @doc """
      Build the signal struct from arbitrary input (or return it if already a signal struct).
      """
      def build(%__MODULE__{} = signal) do
        signal
      end

      @doc """
      Emit the signal from arbitrary input (converted to signal struct if necessary).
      """
      def emit(input) do
        input
        |> build()
        |> unquote(__MODULE__).emit()

        :ok
      end
    end
  end

  defmacro __after_compile__(_env, _bytecode) do
    quote do
      functions = __MODULE__.__info__(:functions)

      unless Keyword.has_key?(functions, :__struct__) do
        raise(
          CompileError,
          description: "defstruct missing in #{inspect(__MODULE__)} signal",
          file: __ENV__.file,
          line: __ENV__.line
        )
      end
    end
  end

  @doc """
  Adds observer module(s) that signal will be emitted to.

  It may be invoked multiple times, but specific observer may be added only once.

  ## Example

  Emit to single observer:

      defmodule MainApp.Accounts.UserRegisteredSignal do
        use Sea.Signal

        emit_to AnalyticsApp.Observer
        emit_to CustomerExperienceApp.Observer
      end

  Emit to multiple observers specified as an array:

      defmodule MainApp.Accounts.UserRegisteredSignal do
        use Sea.Signal

        emit_to [
          MainApp.Mailing.UserRegisteredObserver,
          MainApp.Sales.UserRegisteredObserver
        ]
      end

  Emit to multiple observers specified with the multi-alias syntax:

      defmodule MainApp.Accounts.UserRegisteredSignal do
        use Sea.Signal

        emit_to CustomerExperienceApp.{Mailing, Sales}
      end

  Examples above present multiple approaches to organizing observers. Please refer to *Organizing
  observers* guide for complete explanation and examples on how to approach this problem.
  """
  defmacro emit_to(observer_mod_or_mods)

  defmacro emit_to({{:., _, [base_alias = {:__aliases__, _, _}, :{}]}, _, sub_aliases}) do
    base_mod = Macro.expand(base_alias, __CALLER__)
    nested_mods_names = Enum.map(sub_aliases, &elem(&1, 2))

    observer_mods =
      Enum.map(nested_mods_names, fn nested_mod_names ->
        :"#{base_mod}.#{Enum.join(nested_mod_names, ".")}"
      end)

    quote do
      emit_to(unquote(observer_mods))
    end
  end

  defmacro emit_to(observer_mods) when is_list(observer_mods) do
    Enum.map(observer_mods, fn observer_mod ->
      quote do
        emit_to(unquote(observer_mod))
      end
    end)
  end

  defmacro emit_to(observer_mod) do
    quote do
      if unquote(observer_mod) in @observers_rev do
        raise(
          CompileError,
          description: "observer #{inspect(unquote(observer_mod))} already added",
          file: __ENV__.file,
          line: __ENV__.line
        )
      end

      @observers_rev unquote(observer_mod)
    end
  end

  @doc """
  Emits passed signal struct to observers defined in the struct module.
  """
  def emit(%{__struct__: signal_mod} = signal) do
    observers = signal_mod.__observers__()

    Enum.each(observers, fn observer ->
      observer.handle_signal(signal)
    end)
  end
end
