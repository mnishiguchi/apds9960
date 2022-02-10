defmodule APDS9960.Proximity do
  @moduledoc "The proximity detection."

  alias APDS9960.{Comm, Sensor}

  @doc """
  Returns all the current proximity settings.
  """
  @spec settings(Sensor.t()) :: %{
          enabled: boolean,
          gain: 0..3,
          gain_compensation: %{enabled: boolean, mask: byte},
          interrupt_enabled: boolean,
          interrupt_persistence: byte,
          led_boost: 0..3,
          led_drive: 0..3,
          offset: %{down_left: integer, up_right: integer},
          pulse: %{count: byte, length: 0..3},
          saturation_interrupt_enabled: boolean,
          threshold: %{high: byte, low: byte}
        }
  def settings(%Sensor{} = sensor) do
    %{
      enabled: enabled?(sensor),
      interrupt_enabled: interrupt_enabled?(sensor),
      threshold: get_threshold(sensor),
      interrupt_persistence: get_interrupt_persistence(sensor),
      pulse: get_pulse(sensor),
      gain: get_gain(sensor),
      led_drive: get_led_drive(sensor),
      saturation_interrupt_enabled: saturation_interrupt_enabled?(sensor),
      led_boost: get_led_boost(sensor),
      offset: get_offset(sensor),
      gain_compensation: get_gain_compensation(sensor)
    }
  end

  ## Proximity Enable

  @spec enabled?(Sensor.t()) :: boolean
  def enabled?(%Sensor{transport: i2c}) do
    {:ok, %{proximity: value}} = Comm.get_enable(i2c)
    value == 1
  end

  @spec enable(Sensor.t(), 0 | 1) :: :ok
  def enable(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_enable(i2c, proximity: value)
  end

  @spec interrupt_enabled?(Sensor.t()) :: boolean
  def interrupt_enabled?(%Sensor{transport: i2c}) do
    {:ok, %{proximity_interrupt: value}} = Comm.get_enable(i2c)
    value == 1
  end

  @spec enable_interrupt(Sensor.t(), 0 | 1) :: :ok
  def enable_interrupt(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_enable(i2c, proximity_interrupt: value)
  end

  ## Proximity low/high threshold

  @spec get_threshold(Sensor.t()) :: %{high: byte, low: byte}
  def get_threshold(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_proximity_threshold(i2c)
    %{low: x.low, high: x.high}
  end

  @spec set_threshold(Sensor.t(), Enum.t()) :: :ok
  def set_threshold(%Sensor{transport: i2c}, opts) do
    Comm.set_proximity_threshold(i2c, opts)
  end

  ## Proximity Interrupt Persistence

  @spec get_interrupt_persistence(Sensor.t()) :: 0..15
  def get_interrupt_persistence(%Sensor{transport: i2c}) do
    {:ok, %{proximity: value}} = Comm.get_interrupt_persistence(i2c)
    value
  end

  @spec set_interrupt_persistence(Sensor.t(), 0..15) :: :ok
  def set_interrupt_persistence(%Sensor{transport: i2c}, value) do
    Comm.set_interrupt_persistence(i2c, proximity: value)
  end

  ## Proximity pulse count and length

  @spec get_pulse(Sensor.t()) :: %{count: byte, length: 0..3}
  def get_pulse(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_proximity_pulse(i2c)
    %{count: x.pulse_count, length: x.pulse_length}
  end

  @spec set_pulse(Sensor.t(), Enum.t()) :: :ok
  def set_pulse(%Sensor{transport: i2c}, opts) do
    Comm.set_proximity_pulse(i2c, opts)
  end

  ## Proximity Gain Control

  @spec get_gain(Sensor.t()) :: 0..3
  def get_gain(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_control(i2c)
    x.proximity_gain
  end

  @spec set_gain(Sensor.t(), 0..3) :: :ok
  def set_gain(%Sensor{transport: i2c}, value) do
    Comm.set_control(i2c, proximity_gain: value)
  end

  ## LED Drive Strength

  @spec get_led_drive(Sensor.t()) :: 0..3
  def get_led_drive(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_control(i2c)
    x.led_drive_strength
  end

  @spec set_led_drive(Sensor.t(), 0..3) :: :ok
  def set_led_drive(%Sensor{transport: i2c}, value) do
    Comm.set_control(i2c, led_drive_strength: value)
  end

  ## Proximity Saturation Interrupt Enable

  @spec saturation_interrupt_enabled?(Sensor.t()) :: boolean
  def saturation_interrupt_enabled?(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_config2(i2c)
    x.proximity_saturation_interrupt == 1
  end

  @spec enable_saturation_interrupt(Sensor.t(), 0 | 1) :: :ok
  def enable_saturation_interrupt(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_config2(i2c, proximity_saturation_interrupt: value)
  end

  ## Proximity/Gesture LED Boost

  @spec get_led_boost(Sensor.t()) :: 0..3
  def get_led_boost(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_config2(i2c)
    x.led_boost
  end

  @spec set_led_boost(Sensor.t(), 0..3) :: :ok
  def set_led_boost(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_config2(i2c, led_boost: value)
  end

  ## Proximity Status

  @spec status(Sensor.t()) :: %{interrupt: boolean, saturation: boolean, valid: boolean}
  def status(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.status(i2c)

    %{
      interrupt: x.proximity_interrupt == 1,
      saturation: x.proximity_or_gesture_saturation == 1,
      valid: x.proximity_valid == 1
    }
  end

  ## Proximity Data

  @spec read_proximity(Sensor.t(), Enum.t()) :: byte
  def read_proximity(%Sensor{} = sensor, _opts \\ []) do
    {:ok, data} = Comm.proximity_data(sensor.transport)
    :binary.decode_unsigned(data)
  end

  ## Proximity Offset

  @spec get_offset(Sensor.t()) :: %{down_left: -127..127, up_right: -127..127}
  def get_offset(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_proximity_offset(i2c)

    %{
      up_right: x.up_right,
      down_left: x.down_left
    }
  end

  @spec set_offset(Sensor.t(), Enum.t()) :: :ok
  def set_offset(%Sensor{transport: i2c}, opts) do
    Comm.set_proximity_offset(i2c, opts)
  end

  ## Proximity Gain Compensation Enable

  @spec get_gain_compensation(Sensor.t()) :: %{enabled: boolean, mask: byte}
  def get_gain_compensation(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_config3(i2c)

    %{
      enabled: x.proximity_gain_compensation == 1,
      mask: x.proximity_mask
    }
  end

  @spec set_gain_compensation(Sensor.t(), 0..14) :: :ok
  def set_gain_compensation(%Sensor{transport: i2c}, mask) do
    Comm.set_config3(i2c, mask: mask)
  end

  ## Proximity Interrupt Clear

  @spec clear_interrupt(Sensor.t()) :: :ok
  def clear_interrupt(%Sensor{transport: i2c}) do
    Comm.clear_proximity_interrupt(i2c)
  end
end
