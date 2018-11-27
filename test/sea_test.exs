defmodule SeaTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "multiple signals using varying syntax" do
    defmodule SampleSignal do
      use Sea.Signal

      defstruct [:number_as_string]

      emit_to(SeaTest.Mod1)
      emit_to(SeaTest.{Mod2, Mod3})
      emit_to([SeaTest.Mod4, SeaTest.Mod5])
      emit_within(SeaTest.Mod6)
      emit_within(SeaTest.{Mod7, Mod8})
      emit_within([SeaTest.Mod9, SeaTest.ModA])

      def build(1) do
        %__MODULE__{number_as_string: "one"}
      end
    end

    defmodule Mod1 do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod1 got #{str}")
      end
    end

    defmodule Mod2 do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod2 got #{str}")
      end
    end

    defmodule Mod3 do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod3 got #{str}")
      end
    end

    defmodule Mod4 do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod4 got #{str}")
      end
    end

    defmodule Mod5 do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod5 got #{str}")
      end
    end

    defmodule Mod6.SampleObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod6 got #{str}")
      end
    end

    defmodule Mod7.SampleObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod7 got #{str}")
      end
    end

    defmodule Mod8.SampleObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod8 got #{str}")
      end
    end

    defmodule Mod9.SampleObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("Mod9 got #{str}")
      end
    end

    defmodule ModA.SampleObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%SampleSignal{number_as_string: str}) do
        IO.puts("ModA got #{str}")
      end
    end

    assert capture_io(fn ->
             SampleSignal.emit(1)
           end) == """
           Mod1 got one
           Mod2 got one
           Mod3 got one
           Mod4 got one
           Mod5 got one
           Mod6 got one
           Mod7 got one
           Mod8 got one
           Mod9 got one
           ModA got one
           """
  end

  test "signal mocking" do
    defmodule MockableSignal do
      use Sea.Signal

      defstruct []

      emit_to(SeaTest.MockableObserver)

      def build(:empty), do: %__MODULE__{}
    end

    defmodule MockableObserver do
      use Sea.Observer

      @impl true
      def handle_signal(%MockableSignal{}) do
        IO.puts("MockableObserver called")
      end
    end

    assert capture_io(fn ->
             MockableSignal.emit(:empty)
           end) == """
           MockableObserver called
           """

    Sea.SignalMocking.defsignalmock(MockableSignal)

    assert_raise(Mox.UnexpectedCallError, fn ->
      MockableSignal.Mock.emit(:empty)
    end)

    Sea.SignalMocking.enable_signal(MockableSignal)

    assert capture_io(fn ->
             MockableSignal.Mock.emit(:empty)
           end) == """
           MockableObserver called
           """

    Sea.SignalMocking.disable_signal(MockableSignal)

    assert capture_io(fn ->
             MockableSignal.Mock.emit(:empty)
           end) == """
           """

    Sea.SignalMocking.enable_signal(MockableSignal)

    assert capture_io(fn ->
             MockableSignal.Mock.emit(:empty)
           end) == """
           MockableObserver called
           """
  end
end
