defmodule APDS9960 do
  @moduledoc """
  Use `APDS9960` color, proximity and gesture sensor in Elixir.
  """

  @type gesture_direction :: :up | :down | :left | :right

  defdelegate init(), to: APDS9960.Sensor
  defdelegate init(opts), to: APDS9960.Sensor
  defdelegate enable(sensor, engine), to: APDS9960.Sensor
  defdelegate reset!(sensor), to: APDS9960.Sensor
  defdelegate set_defaults!(sensor), to: APDS9960.Sensor
  defdelegate status(sensor), to: APDS9960.Sensor

  @doc """
  Reads the proximity data. The proximity value is a number from 0 to 255 where the higher the
  number the closer an object is to the sensor.

      # To get a proximity result, first enable the proximity engine.
      APDS9960.enable(sensor, :proximity)

      APDS9960.proximity(sensor)

  """
  @spec proximity(APDS9960.Sensor.t()) :: byte
  def proximity(%APDS9960.Sensor{} = sensor, opts \\ []) do
    APDS9960.Proximity.read_proximity(sensor, opts)
  end

  @doc """
  Reads the color data.

      # To get a color measurement, first enable the color engine.
      APDS9960.enable_color(sensor)

      APDS9960.color(sensor)

  """
  @spec color(APDS9960.Sensor.t()) :: %{
          red: 0..0xFFFF,
          green: 0..0xFFFF,
          blue: 0..0xFFFF,
          clear: 0..0xFFFF
        }
  def color(%APDS9960.Sensor{} = sensor, opts \\ []) do
    APDS9960.ALS.read_color(sensor, opts)
  end

  @doc """
  Reads new gesture engine results, deduces gesture and returns the direction of the gesture.

      # To get a gesture result, first enable both the proximity engine and gesture engine.
      APDS9960.enable(sensor, :gesture)
      APDS9960.enable(sensor, :proximity)

      APDS9960.gesture(sensor, timeout: 5000)

  """
  @spec gesture(APDS9960.Sensor.t(), Enum.t()) :: gesture_direction | {:error, any}
  def gesture(%APDS9960.Sensor{} = sensor, opts \\ []) do
    APDS9960.Gesture.read_gesture(sensor, opts)
  end
end
