defmodule APDS9960.Gesture do
  @moduledoc false

  alias APDS9960.Comm

  use TypedStruct

  @type gesture_direction :: :down | :left | :right | :up

  @type dataset :: {byte, byte, byte, byte}

  typedstruct do
    @typedoc "The gesture data accumulator in the gesture processing loop."

    field(:sensor, t(), enforce: true)
    field(:up_count, non_neg_integer, default: 0)
    field(:down_count, non_neg_integer, default: 0)
    field(:left_count, non_neg_integer, default: 0)
    field(:right_count, non_neg_integer, default: 0)
    field(:deduced_gesture_direction, gesture_direction)
    field(:started_at_ms, integer)
    field(:updated_at_ms, integer)
  end

  @spec new(APDS9960.t()) :: APDS9960.Gesture.t()
  def new(sensor) do
    %__MODULE__{sensor: sensor}
  end

  @spec read_gesture(t(), Enum.t()) :: gesture_direction | {:error, any}
  def read_gesture(%__MODULE__{} = gesture, opts \\ []) do
    timeout = Access.get(opts, :timeout, 5000)
    gesture = %{gesture | started_at_ms: System.monotonic_time(:millisecond)}

    if gesture_available?(gesture) do
      do_read_gesture(gesture, timeout)
    else
      {:error, "gesture not available"}
    end
  end

  @spec do_read_gesture(t(), non_neg_integer) :: gesture_direction | {:error, any}
  defp do_read_gesture(%__MODULE__{} = gesture, timeout) do
    # Wait for new FIFO data.
    Process.sleep(30)

    # Read data from the Gesture FIFO.
    datasets = gesture_fifo(gesture)

    # Filter out useless datasets.
    datasets =
      Enum.filter(datasets, fn {up, down, left, right} ->
        cond do
          up == down and left == right -> false
          (up - down) in -13..13 -> false
          (left - right) in -13..13 -> false
          true -> true
        end
      end)

    if length(datasets) == 0 do
      timeout_or_retry(gesture, timeout)
    else
      [{fifo_up, fifo_down, fifo_left, fifo_right} | _] = datasets
      up_down_diff = fifo_up - fifo_down
      left_right_diff = fifo_left - fifo_right

      gesture = deduce_gesture_direction!(gesture, up_down_diff, left_right_diff)

      if gesture.deduced_gesture_direction do
        gesture.deduced_gesture_direction
      else
        timeout_or_retry(gesture, timeout)
      end
    end
  end

  @spec timeout_or_retry(t(), integer) :: gesture_direction | {:error, any}
  defp timeout_or_retry(%__MODULE__{} = gesture, timeout) do
    if System.monotonic_time(:millisecond) - gesture.started_at_ms > timeout do
      {:error, "timeout #{timeout} ms"}
    else
      do_read_gesture(gesture, timeout)
    end
  end

  @spec deduce_gesture_direction!(t(), integer, integer) :: t()
  defp deduce_gesture_direction!(%__MODULE__{} = gesture, up_down_diff, left_right_diff) do
    gesture =
      cond do
        up_down_diff < 0 ->
          if gesture.down_count > 0 do
            %{gesture | deduced_gesture_direction: :up}
          else
            %{gesture | up_count: gesture.up_count + 1}
          end

        up_down_diff > 0 ->
          if gesture.up_count > 0 do
            %{gesture | deduced_gesture_direction: :down}
          else
            %{gesture | down_count: gesture.down_count + 1}
          end

        true ->
          gesture
      end

    gesture =
      cond do
        left_right_diff < 0 ->
          if gesture.right_count > 0 do
            %{gesture | deduced_gesture_direction: :left}
          else
            %{gesture | left_count: gesture.left_count + 1}
          end

        left_right_diff > 0 ->
          if gesture.left_count > 0 do
            %{gesture | deduced_gesture_direction: :right}
          else
            %{gesture | right_count: gesture.right_count + 1}
          end

        true ->
          gesture
      end

    %{gesture | updated_at_ms: System.monotonic_time(:millisecond)}
  end

  ## Comm helpers

  @spec gesture_available?(t()) :: boolean
  defp gesture_available?(%__MODULE__{} = gesture) do
    {:ok, struct} = Comm.gesture_status(gesture.sensor.transport)
    struct.gesture_valid == 1
  end

  @spec gesture_fifo(t()) :: [dataset]
  defp gesture_fifo(%__MODULE__{} = gesture) do
    # The number of datasets that are currently available in the FIFO for read.
    {:ok, <<dataset_count>>} = Comm.gesture_fifo_level(gesture.sensor.transport)
    {:ok, datasets} = Comm.gesture_fifo(gesture.sensor.transport, dataset_count)
    datasets
  end
end
