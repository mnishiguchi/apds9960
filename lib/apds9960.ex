defmodule APDS9960 do
  @moduledoc """
  Use the digital Color, proximity and gesture sensor `APDS9960` in Elixir.
  """

  alias APDS9960.{Comm, Transport}

  @i2c_address 0x39

  use TypedStruct

  typedstruct do
    @typedoc "The APDS9960 sensor"

    field(:rotation, rotation, enforce: true)
    field(:transport, Transport.t(), enforce: true)
  end

  @typedoc "The APDS9960 sensor option"
  @type option() :: [
          {:bus_name, binary}
          | {:rotation, rotation}
          | {:reset, boolean}
          | {:set_defaults, boolean}
        ]

  @typedoc "The rotation of the device"
  @type rotation :: 0 | 90 | 180 | 270

  @type engine :: :color | :als | :proximity | :gesture

  @type gesture :: :up | :down | :left | :right

  @doc """
  Initializes the I2C bus and sensor.
  """
  @spec init([option]) :: t()
  def init(opts \\ []) do
    bus_name = Access.get(opts, :bus_name, "i2c-1")
    rotation = Access.get(opts, :rotation, 0)
    reset = Access.get(opts, :reset, true)
    set_defaults = Access.get(opts, :set_defaults, true)

    sensor = %__MODULE__{
      rotation: rotation,
      transport: Transport.new(bus_name, @i2c_address)
    }

    :ok = ensure_connected!(sensor)

    if reset, do: reset!(sensor)
    if set_defaults, do: set_defaults!(sensor)

    sensor
  end

  @spec ensure_connected!(t()) :: :ok
  defp ensure_connected!(%__MODULE__{transport: i2c}) do
    true = Comm.connected?(i2c)
    :ok
  end

  @spec reset!(t()) :: :ok
  def reset!(%__MODULE__{transport: i2c}) do
    # Disable prox, gesture, and color engines
    :ok = Comm.set_enable(i2c, gesture: 0, proximity: 0, als: 0)

    # Reset basic config registers to power-on defaults
    :ok = Comm.set_proximity_l_threshold(i2c, <<0>>)
    :ok = Comm.set_proximity_h_threshold(i2c, <<0>>)
    :ok = Comm.set_interrupt_persistence(i2c, <<0>>)
    :ok = Comm.set_gesture_proximity_enter_threshold(i2c, <<0>>)
    :ok = Comm.set_gesture_exit_threshold(i2c, <<0>>)
    :ok = Comm.set_gesture_conf1(i2c, <<0>>)
    :ok = Comm.set_gesture_conf2(i2c, <<0>>)
    :ok = Comm.set_gesture_conf4(i2c, <<0>>)
    :ok = Comm.set_gesture_pulse_count(i2c, <<0>>)
    :ok = Comm.set_adc_integration_time(i2c, <<255>>)
    :ok = Comm.set_control(i2c, als_and_color_gain: 1)

    # Clear all non-gesture interrupts
    :ok = Comm.clear_all_non_gesture_interrupts(i2c)

    # Disable sensor and all functions/interrupts
    :ok = Comm.set_enable(i2c, <<0>>)
    :ok = Process.sleep(25)

    # Re-enable sensor and wait 10ms for the power on delay to finish
    :ok = Comm.set_enable(i2c, power: 1)
    :ok = Process.sleep(10)

    :ok
  end

  @spec set_defaults!(t()) :: :ok
  def set_defaults!(%__MODULE__{transport: i2c}) do
    # Trigger proximity interrupt at >= 5, PPERS: 4 cycles
    :ok = Comm.set_proximity_l_threshold(i2c, <<0>>)
    :ok = Comm.set_proximity_h_threshold(i2c, <<5>>)
    :ok = Comm.set_interrupt_persistence(i2c, proximity: 4)

    # Enter gesture engine at >= 5 proximity counts
    :ok = Comm.set_gesture_proximity_enter_threshold(i2c, <<5>>)

    # Exit gesture engine if all counts drop below 30
    :ok = Comm.set_gesture_exit_threshold(i2c, <<30>>)

    # GEXPERS: 2 (4 cycles), GEXMSK: 0 (default) GFIFOTH: 2 (8 datasets)
    :ok =
      Comm.set_gesture_conf1(i2c,
        gesture_fifo_threshold: 2,
        gesture_exit_mask: 0,
        gesture_exit_persistence: 2
      )

    # GGAIN: 2 (4x), GLDRIVE: 0 (100 mA), GWTIME: 1 (2.8 ms)
    :ok =
      Comm.set_gesture_conf2(i2c,
        gesture_gain: 2,
        gesture_led_drive_strength: 0,
        gesture_wait_time: 1
      )

    # GPULSE: 5 (6 pulses), GPLEN: 2 (16 us)
    :ok =
      Comm.set_gesture_pulse_count(i2c,
        gesture_pulse_count: 5,
        gesture_pulse_length: 2
      )

    # ATIME: 0 (712ms color integration time, max count of 65535)
    :ok = Comm.set_adc_integration_time(i2c, <<0>>)

    # AGAIN: 1 (4x color gain)
    :ok = Comm.set_control(i2c, als_and_color_gain: 1)

    :ok
  end

  @doc """
  Returns the status of the device.
  """
  @spec status(t()) :: %{
          als_interrupt: byte,
          als_valid: byte,
          clear_photo_diode_saturation: byte,
          gesture_interrupt: byte,
          proximity_interrupt: byte,
          proximity_or_gesture_saturation: byte,
          proximity_valid: byte
        }
  def status(%__MODULE__{transport: i2c}) do
    {:ok, struct} = Comm.status(i2c)
    Map.from_struct(struct)
  end

  @doc """
  Reads the proximity data. The proximity value is a number from 0 to 255 where the higher the
  number the closer an object is to the sensor.

      # To get a proximity result, first enable the proximity engine.
      APDS9960.enable(sensor, :proximity)

      APDS9960.proximity(sensor)

  """
  @spec proximity(t()) :: byte
  def proximity(%__MODULE__{transport: i2c}) do
    {:ok, <<byte>>} = Comm.proximity_data(i2c)
    byte
  end

  @doc """
  Reads the color data.

      # To get a color measurement, first enable the color engine.
      APDS9960.enable_color(sensor)

      APDS9960.color(sensor)

  """
  @spec color(t()) :: %{red: 0..0xFFFF, green: 0..0xFFFF, blue: 0..0xFFFF, clear: 0..0xFFFF}
  def color(%__MODULE__{transport: i2c}) do
    {:ok, struct} = Comm.color_data(i2c)
    Map.from_struct(struct)
  end

  @doc """
  Enable an engine for a desired feature.
  """
  @spec enable(t(), engine) :: :ok
  def enable(%__MODULE__{transport: i2c}, :color), do: Comm.set_enable(i2c, als: 1)
  def enable(%__MODULE__{transport: i2c}, engine), do: Comm.set_enable(i2c, [{engine, 1}])
end
