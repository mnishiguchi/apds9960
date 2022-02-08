defmodule APDS9960.ALS do
  @moduledoc "The ambient light and RGB color sensing."

  alias APDS9960.{Comm, Sensor}

  @doc """
  Returns all the current Color / ALS settings.
  """
  @spec settings(Sensor.t()) :: %{
          adc_integration_time: byte,
          enabled: boolean,
          gain: 0..3,
          interrupt_enabled: boolean,
          interrupt_persistence: byte,
          saturation_interrupt: boolean,
          threshold: %{high: 0xFFFF, low: 0xFFFF},
          wait_long_enabled: boolean,
          wait_time: byte
        }
  def settings(%Sensor{} = sensor) do
    %{
      enabled: enabled?(sensor),
      interrupt_enabled: interrupt_enabled?(sensor),
      adc_integration_time: get_adc_integration_time(sensor),
      wait_time: get_wait_time(sensor),
      threshold: get_threshold(sensor),
      interrupt_persistence: get_interrupt_persistence(sensor),
      wait_long_enabled: wait_long_enabled?(sensor),
      gain: get_gain(sensor),
      saturation_interrupt: saturation_interrupt_enabled?(sensor)
    }
  end

  ## ALS Enable

  @spec enabled?(Sensor.t()) :: boolean
  def enabled?(%Sensor{transport: i2c}) do
    {:ok, %{als: value}} = Comm.get_enable(i2c)
    value == 1
  end

  @spec enable(Sensor.t(), 0 | 1) :: :ok
  def enable(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_enable(i2c, als: value)
  end

  @spec interrupt_enabled?(Sensor.t()) :: boolean
  def interrupt_enabled?(%Sensor{transport: i2c}) do
    {:ok, %{als_interrupt: value}} = Comm.get_enable(i2c)
    value == 1
  end

  @spec enable_interrupt(Sensor.t(), 0 | 1) :: :ok
  def enable_interrupt(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_enable(i2c, als_interrupt: value)
  end

  @spec wait_enabled?(Sensor.t()) :: boolean
  def wait_enabled?(%Sensor{transport: i2c}) do
    {:ok, %{wait: value}} = Comm.get_enable(i2c)
    value == 1
  end

  @spec enable_wait(Sensor.t(), 0 | 1) :: :ok
  def enable_wait(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_enable(i2c, wait: value)
  end

  ## ALS ADC Integration Time

  @spec get_adc_integration_time(Sensor.t()) :: byte
  def get_adc_integration_time(%Sensor{transport: i2c}) do
    {:ok, data} = Comm.get_adc_integration_time(i2c)
    :binary.decode_unsigned(data)
  end

  @spec set_adc_integration_time(Sensor.t(), byte) :: :ok
  def set_adc_integration_time(%Sensor{transport: i2c}, byte) do
    Comm.set_adc_integration_time(i2c, <<byte>>)
  end

  ## Wait Time

  @spec get_wait_time(Sensor.t()) :: byte
  def get_wait_time(%Sensor{transport: i2c}) do
    {:ok, data} = Comm.get_wait_time(i2c)
    :binary.decode_unsigned(data)
  end

  @spec set_wait_time(Sensor.t(), byte) :: :ok
  def set_wait_time(%Sensor{transport: i2c}, byte) do
    Comm.set_wait_time(i2c, <<byte>>)
  end

  ## ALS low/high threshold

  @spec get_threshold(Sensor.t()) :: %{high: 0..0xFFFF, low: 0..0xFFFF}
  def get_threshold(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_als_threshold(i2c)
    %{low: x.low, high: x.high}
  end

  @spec set_threshold(Sensor.t(), {low :: 0..0xFFFF, high :: 0..0xFFFF}) :: :ok
  def set_threshold(%Sensor{transport: i2c}, {low, high}) do
    Comm.set_als_threshold(i2c, {low, high})
  end

  ## ALS Interrupt Persistence

  @spec get_interrupt_persistence(Sensor.t()) :: 0..15
  def get_interrupt_persistence(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_interrupt_persistence(i2c)
    x.als
  end

  @spec set_interrupt_persistence(Sensor.t(), 0..15) :: :ok
  def set_interrupt_persistence(%Sensor{transport: i2c}, byte) do
    Comm.set_interrupt_persistence(i2c, als: byte)
  end

  ## Wait Long Enable

  @spec wait_long_enabled?(Sensor.t()) :: boolean
  def wait_long_enabled?(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_config1(i2c)
    x.wait_long == 1
  end

  @spec enable_wait_long(Sensor.t(), 0 | 1) :: :ok
  def enable_wait_long(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_config1(i2c, wait_long: value)
  end

  ## ALS Gain Control

  @spec get_gain(Sensor.t()) :: 0..3
  def get_gain(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_control(i2c)
    x.als_and_color_gain
  end

  @spec set_gain(Sensor.t(), 0..3) :: :ok
  def set_gain(%Sensor{transport: i2c}, value) do
    Comm.set_control(i2c, als_and_color_gain: value)
  end

  ## Clear diode Saturation Interrupt Enable

  @spec saturation_interrupt_enabled?(Sensor.t()) :: boolean
  def saturation_interrupt_enabled?(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.get_config2(i2c)
    x.als_saturation_interrupt == 1
  end

  @spec enable_saturation_interrupt(Sensor.t(), 0 | 1) :: :ok
  def enable_saturation_interrupt(%Sensor{transport: i2c}, value \\ 1) do
    Comm.set_config2(i2c, als_saturation_interrupt: value)
  end

  ## ALS Status

  @spec status(Sensor.t()) :: %{
          clear_photo_diode_saturation: boolean,
          interrupt: boolean,
          valid: boolean
        }
  def status(%Sensor{transport: i2c}) do
    {:ok, x} = Comm.status(i2c)

    %{
      interrupt: x.als_interrupt == 1,
      valid: x.als_valid == 1,
      clear_photo_diode_saturation: x.als_interrupt == 1
    }
  end

  ## Color Data

  @spec read_color(Sensor.t(), Enum.t()) :: %{
          red: 0..0xFFFF,
          green: 0..0xFFFF,
          blue: 0..0xFFFF,
          clear: 0..0xFFFF
        }
  def read_color(%Sensor{} = sensor, _opts \\ []) do
    {:ok, x} = Comm.color_data(sensor.transport)

    %{
      red: x.red,
      green: x.green,
      blue: x.blue,
      clear: x.clear
    }
  end

  # Clear Channel Interrupt Clear

  @spec clear_interrupt(Sensor.t()) :: :ok
  def clear_interrupt(%Sensor{transport: i2c}) do
    Comm.clear_als_clear_channel_interrupt(i2c)
  end
end
