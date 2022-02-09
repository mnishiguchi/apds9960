defmodule APDS9960.Gesture do
  @moduledoc "The gesture detection."

  alias APDS9960.{Comm, Gesture, Sensor}

  use TypedStruct

  @type gesture_direction :: :down | :left | :right | :up

  @typep dataset :: {byte, byte, byte, byte}

  typedstruct do
    @typedoc "The gesture data accumulator in the gesture processing loop."

    field(:sensor, Sensor.t(), enforce: true)
    field(:up_count, non_neg_integer, default: 0)
    field(:down_count, non_neg_integer, default: 0)
    field(:left_count, non_neg_integer, default: 0)
    field(:right_count, non_neg_integer, default: 0)
    field(:deduced_gesture_direction, gesture_direction)
    field(:started_at_ms, integer)
    field(:updated_at_ms, integer)
  end

  @spec read_gesture(Sensor.t(), Enum.t()) :: gesture_direction | {:error, any}
  def read_gesture(%Sensor{} = sensor, opts \\ []) do
    gesture = %Gesture{sensor: sensor, started_at_ms: System.monotonic_time(:millisecond)}
    timeout = Access.get(opts, :timeout, 5000)

    if valid?(sensor) do
      do_read_gesture(gesture, timeout)
    else
      {:error, "gesture not available"}
    end
  end

  @spec do_read_gesture(t(), non_neg_integer) :: gesture_direction | {:error, any}
  defp do_read_gesture(%Gesture{sensor: sensor} = gesture, timeout) do
    # Wait for new FIFO data.
    Process.sleep(30)

    # Read data from the Gesture FIFO.
    datasets = gesture_fifo(sensor, fifo_level(sensor))

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
  defp timeout_or_retry(%Gesture{} = gesture, timeout) do
    if System.monotonic_time(:millisecond) - gesture.started_at_ms > timeout do
      {:error, "timeout #{timeout} ms"}
    else
      do_read_gesture(gesture, timeout)
    end
  end

  @spec deduce_gesture_direction!(t(), integer, integer) :: t()
  defp deduce_gesture_direction!(%Gesture{} = gesture, up_down_diff, left_right_diff) do
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

  @spec settings(Sensor.t()) :: %{
          dimension: 0..3,
          enabled: boolean,
          exit_mask: byte,
          exit_persistence: 0..3,
          fifo_threshold: 0..3,
          gain: 0..3,
          interrupt_enabled: boolean,
          led_boost: 0..3,
          led_drive_strength: 0..3,
          offset: %{down: integer, left: integer, right: integer, up: integer},
          pulse: %{count: byte, length: 0..3},
          threshold: %{enter: byte, exit: byte},
          wait_time: 0..7
        }
  def settings(%Sensor{} = sensor) do
    %{
      enabled: enabled?(sensor),
      interrupt_enabled: interrupt_enabled?(sensor),
      threshold: get_threshold(sensor),
      fifo_threshold: get_fifo_threshold(sensor),
      exit_mask: get_gesture_exit_mask(sensor),
      exit_persistence: get_exit_persistence(sensor),
      gain: get_gain(sensor),
      led_drive_strength: get_led_drive_strength(sensor),
      wait_time: get_wait_time(sensor),
      led_boost: get_led_boost(sensor),
      offset: get_offset(sensor),
      pulse: get_pulse(sensor),
      dimension: get_dimension(sensor)
    }
  end

  @spec status(Sensor.t()) :: %{
          fifo_overflow: boolean,
          saturation: boolean,
          valid: boolean
        }
  def status(%Sensor{transport: i2c}) do
    {:ok, s} = Comm.status(i2c)
    {:ok, gs} = Comm.gesture_status(i2c)

    %{
      saturation: s.proximity_or_gesture_saturation == 1,
      valid: gs.valid == 1,
      fifo_overflow: gs.fifo_overflow == 1
    }
  end

  ## Gesture Enable

  @spec enabled?(Sensor.t()) :: boolean
  def enabled?(%Sensor{transport: i2c}) do
    {:ok, %{gesture: value}} = Comm.get_enable(i2c)
    value == 1
  end

  @spec enable(Sensor.t(), 0 | 1) :: :ok
  def enable(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_enable(i2c, gesture: value)
  end

  ## Gesture Proximity Enter/Exit Threshold

  @spec get_threshold(Sensor.t()) :: %{enter: byte, exit: byte}
  def get_threshold(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_proximity_threshold(i2c)
    %{enter: x.enter, exit: x.exit}
  end

  @spec set_threshold(Sensor.t(), Enum.t()) :: :ok
  def set_threshold(%Sensor{transport: i2c}, opts) do
    Comm.set_gesture_proximity_threshold(i2c, opts)
  end

  ## Gesture FIFO Threshold

  @spec get_fifo_threshold(Sensor.t()) :: 0..3
  def get_fifo_threshold(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf1(i2c)
    x.fifo_threshold
  end

  @spec set_fifo_threshold(Sensor.t(), 0..3) :: :ok
  def set_fifo_threshold(%Sensor{transport: i2c}, value) do
    Comm.set_gesture_conf1(i2c, fifo_threshold: value)
  end

  ## Gesture Exit Mask

  @spec get_gesture_exit_mask(APDS9960.Sensor.t()) :: 0x0000..0x1111
  def get_gesture_exit_mask(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf1(i2c)
    x.exit_mask
  end

  @spec set_gesture_exit_mask(Sensor.t(), Enum.t()) :: :ok
  def set_gesture_exit_mask(%Sensor{transport: i2c}, opts) do
    Comm.set_gesture_conf1(i2c, opts)
  end

  ## Gesture Exit Persistence

  @spec get_exit_persistence(Sensor.t()) :: 0..3
  def get_exit_persistence(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf1(i2c)
    x.exit_persistence
  end

  @spec set_exit_persistence(Sensor.t(), 0..3) :: :ok
  def set_exit_persistence(%Sensor{transport: i2c}, value) do
    Comm.set_gesture_conf1(i2c, exit_persistence: value)
  end

  ## Gesture Gain Control

  @spec get_gain(Sensor.t()) :: 0..3
  def get_gain(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf2(i2c)
    x.gain
  end

  @spec set_gain(Sensor.t(), 0..3) :: :ok
  def set_gain(%Sensor{transport: i2c}, value) do
    Comm.set_gesture_conf2(i2c, gain: value)
  end

  ## Gesture LED Drive Strength

  @spec get_led_drive_strength(Sensor.t()) :: 0..3
  def get_led_drive_strength(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf2(i2c)
    x.led_drive_strength
  end

  @spec set_led_drive_strength(Sensor.t(), 0..3) :: :ok
  def set_led_drive_strength(%Sensor{transport: i2c}, value) do
    Comm.set_gesture_conf2(i2c, led_drive_strength: value)
  end

  ## Gesture Wait Time

  @spec get_wait_time(Sensor.t()) :: 0..7
  def get_wait_time(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf2(i2c)
    x.wait_time
  end

  @spec set_wait_time(Sensor.t(), 0..7) :: :ok
  def set_wait_time(%Sensor{transport: i2c}, value) do
    Comm.set_gesture_conf2(i2c, wait_time: value)
  end

  ## Gesture Saturation

  @spec saturation?(Sensor.t()) :: boolean
  def saturation?(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.status(i2c)
    x.proximity_or_gesture_saturation == 1
  end

  ## Gesture LED Boost

  @spec get_led_boost(Sensor.t()) :: 0..3
  def get_led_boost(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_config2(i2c)
    x.led_boost
  end

  @spec set_led_boost(Sensor.t(), 0..3) :: :ok
  def set_led_boost(%Sensor{transport: i2c}, value) do
    Comm.set_config2(i2c, led_boost: value)
  end

  ## Gesture Offset, UP/DOWN/LEFT/RIGHT

  @spec get_offset(Sensor.t()) ::
          %{down: -127..127, left: -127..127, right: -127..127, up: -127..127}
  def get_offset(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_offset(i2c)
    x
  end

  @spec set_offset(Sensor.t(), Enum.t()) :: :ok
  def set_offset(%Sensor{transport: i2c}, opts) do
    Comm.set_gesture_offset(i2c, opts)
  end

  ## Gesture Pulse

  @spec get_pulse(Sensor.t()) :: %{count: 0..63, length: 0..3}
  def get_pulse(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_pulse(i2c)
    %{count: x.pulse_count, length: x.pulse_length}
  end

  def set_pulse(%Sensor{transport: i2c}, opts) do
    Comm.set_gesture_pulse(i2c, opts)
  end

  ## Gesture Dimension Select

  @spec get_dimension(Sensor.t()) :: 0..3
  def get_dimension(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf3(i2c)
    x.dimension
  end

  @spec set_dimension(Sensor.t(), 0..3) :: :ok
  def set_dimension(%Sensor{transport: i2c}, value) do
    Comm.set_gesture_conf3(i2c, dimension: value)
  end

  ## Gesture Interrupt Enable

  @spec interrupt_enabled?(Sensor.t()) :: boolean
  def interrupt_enabled?(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf4(i2c)
    x.interrupt == 1
  end

  @spec enable_interrupt(Sensor.t(), 0 | 1) :: :ok
  def enable_interrupt(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_gesture_conf4(i2c, interrupt: value)
  end

  ## Gesture Mode

  @spec get_mode(Sensor.t()) :: 0 | 1
  def get_mode(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_gesture_conf4(i2c)
    x.mode
  end

  def set_mode(%Sensor{transport: i2c}, value) do
    Comm.set_gesture_conf4(i2c, mode: value)
  end

  ## Gesture FIFO Level

  @doc "The number of datasets that are currently available in the FIFO for read."
  @spec fifo_level(Sensor.t()) :: byte
  def fifo_level(%Sensor{transport: i2c}) do
    {:ok, <<dataset_count>>} = Comm.gesture_fifo_level(i2c)
    dataset_count
  end

  ## Gesture FIFO Overflow

  @spec fifo_overflow?(Sensor.t()) :: boolean
  def fifo_overflow?(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.gesture_status(i2c)
    x.fifo_overflow == 1
  end

  ## Gesture Valid

  @spec valid?(Sensor.t()) :: boolean
  def valid?(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.gesture_status(i2c)
    x.valid == 1
  end

  ## Gesture FIFO UP/DOWN/LEFT/RIGHT

  @spec gesture_fifo(Sensor.t(), non_neg_integer()) :: [dataset]
  def gesture_fifo(%Sensor{transport: i2c}, dataset_count) do
    {:ok, datasets} = Comm.gesture_fifo(i2c, dataset_count)
    datasets
  end
end
