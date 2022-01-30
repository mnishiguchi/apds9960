defmodule APDS9960.Comm do
  @moduledoc false

  alias APDS9960.{Register, Transport}

  @device_id 0xAB

  @spec connected?(Transport.t()) :: boolean
  def connected?(%Transport{} = i2c) do
    case i2c.write_read_fn.([Register.ID.address()], 1) do
      {:ok, <<id>>} when id == @device_id -> true
      _ -> false
    end
  end

  ## 0x80 ENABLE Read/Write Enable states and interrupts

  @spec get_enable(Transport.t()) :: {:ok, struct}
  def get_enable(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.ENABLE.address()], 1)
    {:ok, Register.ENABLE.parse(data)}
  end

  @spec set_enable(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_enable(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.ENABLE.address(), byte])
  end

  def set_enable(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_enable(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.data()
    i2c.write_fn.([Register.ENABLE.address(), new_data])
  end

  ## 0x81 ATIME Read/Write ADC integration time

  @spec get_adc_integration_time(Transport.t()) :: {:ok, <<_::8>>}
  def get_adc_integration_time(%Transport{} = i2c) do
    i2c.write_read_fn.([Register.ATIME.address()], 1)
  end

  @spec set_adc_integration_time(Transport.t(), <<_::8>>) :: :ok
  def set_adc_integration_time(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.ATIME.address(), byte])
  end

  ## 0x89 PILT Read/Write Proximity interrupt low threshold

  @spec get_proximity_thresholds(Transport.t()) :: {:ok, <<_::8>>}
  def get_proximity_thresholds(%Transport{} = i2c) do
    i2c.write_read_fn.([Register.PILT.address()], 2)
  end

  @spec set_proximity_threshold(Transport.t(), <<_::16>> | {low :: byte, high :: byte}) :: :ok
  def set_proximity_threshold(%Transport{} = i2c, <<low, high>>) do
    i2c.write_fn.([Register.PILT.address(), <<low, high>>])
  end

  def set_proximity_threshold(%Transport{} = i2c, {low, high}) do
    i2c.write_fn.([Register.PILT.address(), <<low, high>>])
  end

  ## 0x8C PERS Read/Write Interrupt persistence filters (non-gesture)

  @spec get_interrupt_persistence(Transport.t()) :: {:ok, Register.PERS.t()}
  def get_interrupt_persistence(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.PERS.address()], 1)
    {:ok, Register.PERS.parse(data)}
  end

  @spec set_interrupt_persistence(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_interrupt_persistence(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.PERS.address(), byte])
  end

  def set_interrupt_persistence(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_interrupt_persistence(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.data()
    i2c.write_fn.([Register.PERS.address(), new_data])
  end

  ## 0x8F CONTROL Read/Write Gain control

  @spec get_control(Transport.t()) :: {:ok, Register.CONTROL.t()}
  def get_control(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.CONTROL.address()], 1)
    {:ok, Register.CONTROL.parse(data)}
  end

  @spec set_control(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_control(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.CONTROL.address(), byte])
  end

  def set_control(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_control(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.data()
    i2c.write_fn.([Register.CONTROL.address(), new_data])
  end

  ## 0x93 STATUS Read-only Device status

  @spec status(Transport.t()) :: {:ok, Register.STATUS.t()}
  def status(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.STATUS.address()], 1)
    {:ok, Register.STATUS.parse(data)}
  end

  ## 0x94 CDATAL Read-only Color data (2 bytes

  @spec color_data(Transport.t()) :: {:ok, Register.CDATAL.t()}
  def color_data(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.CDATAL.address()], 8)
    {:ok, Register.CDATAL.parse(data)}
  end

  ## 0x9C PDATA Read-only Proximity data

  @spec proximity_data(Transport.t()) :: {:ok, <<_::8>>}
  def proximity_data(%Transport{} = i2c) do
    i2c.write_read_fn.([Register.PDATA.address()], 1)
  end

  ## 0xA0 GPENTH Read/Write Gesture proximity enter threshold

  @spec set_gesture_proximity_enter_threshold(Transport.t(), <<_::8>>) :: :ok
  def set_gesture_proximity_enter_threshold(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GPENTH.address(), byte])
  end

  ## 0xA1 GEXTH R/W Gesture exit threshold

  @spec set_gesture_exit_threshold(Transport.t(), <<_::8>>) :: :ok
  def set_gesture_exit_threshold(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GEXTH.address(), byte])
  end

  ## 0xA2 GCONF1 Read/Write Gesture configuration one

  @spec get_gesture_conf1(Transport.t()) :: {:ok, Register.GCONF1.t()}
  def get_gesture_conf1(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GCONF1.address()], 1)
    {:ok, Register.GCONF1.parse(data)}
  end

  @spec set_gesture_conf1(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_gesture_conf1(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GCONF1.address(), byte])
  end

  def set_gesture_conf1(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_conf1(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.data()
    i2c.write_fn.([Register.GCONF1.address(), new_data])
  end

  ## 0xA3 GCONF2 Read/Write Gesture configuration two

  @spec get_gesture_conf2(Transport.t()) :: {:ok, Register.GCONF2.t()}
  def get_gesture_conf2(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GCONF2.address()], 1)
    {:ok, Register.GCONF2.parse(data)}
  end

  @spec set_gesture_conf2(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_gesture_conf2(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GCONF2.address(), byte])
  end

  def set_gesture_conf2(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_conf2(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.data()
    i2c.write_fn.([Register.GCONF2.address(), new_data])
  end

  ## 0xA6 GPULSE Read/Write Gesture pulse count and length

  @spec get_gesture_pulse_count(Transport.t()) :: {:ok, Register.GPULSE.t()}
  def get_gesture_pulse_count(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GPULSE.address()], 1)
    {:ok, Register.GPULSE.parse(data)}
  end

  @spec set_gesture_pulse_count(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_gesture_pulse_count(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GPULSE.address(), byte])
  end

  def set_gesture_pulse_count(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_pulse_count(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.data()
    i2c.write_fn.([Register.GPULSE.address(), new_data])
  end

  ## 0xAB GCONF4 Read/Write Gesture configuration four

  @spec get_gesture_conf4(Transport.t()) :: {:ok, Register.GCONF4.t()}
  def get_gesture_conf4(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GCONF4.address()], 1)
    {:ok, Register.GCONF4.parse(data)}
  end

  @spec set_gesture_conf4(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_gesture_conf4(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GCONF4.address(), byte])
  end

  def set_gesture_conf4(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_conf4(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.data()
    i2c.write_fn.([Register.GCONF4.address(), new_data])
  end

  ## 0xAE GFLVL Read-only Gesture FIFO level

  @spec gesture_fifo_level(Transport.t()) :: {:ok, <<_::8>>}
  def gesture_fifo_level(%Transport{} = i2c) do
    i2c.write_read_fn.([Register.GFLVL.address()], 1)
  end

  ## 0xAF GSTATUS Read-only Gesture status

  @spec gesture_status(Transport.t()) :: {:ok, Register.GSTATUS.t()}
  def gesture_status(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GSTATUS.address()], 1)
    {:ok, Register.GSTATUS.parse(data)}
  end

  ## 0xE7 AICLEAR Write-only All non-gesture interrupts clear

  @spec clear_all_non_gesture_interrupts(Transport.t()) :: :ok
  def clear_all_non_gesture_interrupts(%Transport{} = i2c) do
    i2c.write_fn.([Register.AICLEAR.address()])
  end

  ## 0xFC GFIFO_U Read-only Gesture FIFO UP/DOWN/LEFT/RIGHT values

  @spec gesture_fifo(APDS9960.Transport.t(), byte) :: {:ok, [{byte, byte, byte, byte}]}
  def gesture_fifo(%Transport{} = i2c, dataset_count) do
    {:ok, data} = i2c.write_read_fn.([Register.GFIFO_U.address()], dataset_count * 4)
    {:ok, Register.GFIFO_U.parse(data) |> Enum.slice(0, dataset_count)}
  end
end
