defmodule APDS9960.Sensor do
  @moduledoc "The APDS9960 sensor."

  alias APDS9960.{Comm, Sensor, Transport}

  @i2c_address 0x39

  use TypedStruct

  typedstruct do
    field(:transport, Transport.t(), enforce: true)
  end

  @typedoc "The APDS9960 sensor option"
  @type option() :: [
          {:bus_name, binary}
          | {:reset, boolean}
          | {:set_defaults, boolean}
        ]

  @type engine :: :color | :als | :proximity | :gesture

  @type gesture_direction :: :up | :down | :left | :right

  @doc "Initializes the I2C bus and sensor."
  @spec init([option]) :: t()
  def init(opts \\ []) do
    bus_name = Access.get(opts, :bus_name, "i2c-1")
    reset = Access.get(opts, :reset, true)
    set_defaults = Access.get(opts, :set_defaults, true)

    sensor = %Sensor{
      transport: Transport.new(bus_name, @i2c_address)
    }

    :ok = ensure_connected!(sensor)

    if reset, do: reset!(sensor)
    if set_defaults, do: set_defaults!(sensor)

    %Sensor{} = sensor
  end

  @spec ensure_connected!(Sensor.t()) :: :ok
  defp ensure_connected!(%Sensor{transport: i2c}) do
    true = Comm.connected?(i2c)
    :ok
  end

  @spec reset!(Sensor.t()) :: :ok
  def reset!(%Sensor{transport: i2c}) do
    # Disable prox, gesture, and color engines
    :ok = Comm.set_enable(i2c, gesture: 0, proximity: 0, als: 0)

    # Reset basic config registers to power-on defaults
    :ok = Comm.set_proximity_threshold(i2c, low: 0, high: 0)
    :ok = Comm.set_interrupt_persistence(i2c, <<0>>)
    :ok = Comm.set_gesture_proximity_threshold(i2c, enter: 0, exit: 0)
    :ok = Comm.set_gesture_conf1(i2c, <<0>>)
    :ok = Comm.set_gesture_conf2(i2c, <<0>>)
    :ok = Comm.set_gesture_conf4(i2c, <<0>>)
    :ok = Comm.set_gesture_pulse(i2c, <<0>>)
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

  @spec set_defaults!(Sensor.t()) :: :ok
  def set_defaults!(%Sensor{transport: i2c}) do
    # Trigger proximity interrupt at >= 5, PPERS: 4 cycles
    :ok = Comm.set_proximity_threshold(i2c, low: 0, high: 5)
    :ok = Comm.set_interrupt_persistence(i2c, proximity: 4)

    # Enter gesture engine at >= 5 proximity counts
    # Exit gesture engine if all counts drop below 30
    :ok = Comm.set_gesture_proximity_threshold(i2c, enter: 5, exit: 30)

    # GEXPERS: 2 (4 cycles), GEXMSK: 0 (default) GFIFOTH: 2 (8 datasets)
    :ok =
      Comm.set_gesture_conf1(i2c,
        fifo_threshold: 2,
        exit_mask: 0,
        exit_persistence: 2
      )

    # GGAIN: 2 (4x), GLDRIVE: 0 (100 mA), GWTIME: 1 (2.8 ms)
    :ok =
      Comm.set_gesture_conf2(i2c,
        gain: 2,
        led_drive_strength: 0,
        wait_time: 1
      )

    # GPULSE: 5 (6 pulses), GPLEN: 2 (16 us)
    :ok =
      Comm.set_gesture_pulse(i2c,
        pulse_count: 5,
        pulse_length: 2
      )

    # ATIME: 0 (712ms color integration time, max count of 65535)
    :ok = Comm.set_adc_integration_time(i2c, <<0>>)

    # AGAIN: 1 (4x color gain)
    :ok = Comm.set_control(i2c, als_and_color_gain: 1)

    :ok
  end

  @doc "Enable an engine for a desired feature."
  @spec enable(Sensor.t(), engine) :: :ok
  def enable(%Sensor{transport: i2c}, :color), do: Comm.set_enable(i2c, als: 1)
  def enable(%Sensor{transport: i2c}, engine), do: Comm.set_enable(i2c, [{engine, 1}])
end
