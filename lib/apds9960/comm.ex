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
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
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

  ## 0x83 WTIME Read/Write Wait time (non-gesture)

  @spec get_wait_time(Transport.t()) :: {:ok, <<_::8>>}
  def get_wait_time(%Transport{} = i2c) do
    i2c.write_read_fn.([Register.WTIME.address()], 1)
  end

  @spec set_wait_time(Transport.t(), <<_::8>>) :: :ok
  def set_wait_time(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.WTIME.address(), byte])
  end

  ## 0x84 AILTL Read/Write ALS interrupt low/high threshold

  @spec get_als_threshold(Transport.t()) :: {:ok, Register.AILTL.t()}
  def get_als_threshold(%Transport{} = i2c) do
    {:ok, <<_::32>> = data} = i2c.write_read_fn.([Register.AILTL.address()], 4)
    {:ok, Register.AILTL.parse(data)}
  end

  @spec set_als_threshold(Transport.t(), {low :: 0..0xFFFF, high :: 0..0xFFFF}) :: :ok
  def set_als_threshold(%Transport{} = i2c, {low, high}) do
    i2c.write_fn.([Register.AILTL.address(), <<low::little-16, high::little-16>>])
  end

  ## 0x89 PILT Read/Write Proximity interrupt low threshold

  @spec get_proximity_threshold(Transport.t()) :: {:ok, Register.PILT.t()}
  def get_proximity_threshold(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.PILT.address()], 2)
    {:ok, Register.PILT.parse(data)}
  end

  @spec set_proximity_threshold(Transport.t(), <<_::16>> | Enum.t()) :: :ok
  def set_proximity_threshold(%Transport{} = i2c, <<low, high>>) do
    i2c.write_fn.([Register.PILT.address(), <<low, high>>])
  end

  def set_proximity_threshold(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_proximity_threshold(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.PILT.address(), new_data])
  end

  ## 0x8C PERS Read/Write Interrupt persistence filters (non-gesture)

  @spec get_interrupt_persistence(Transport.t()) :: {:ok, Register.PERS.t()}
  def get_interrupt_persistence(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.PERS.address()], 1)
    {:ok, Register.PERS.parse(data)}
  end

  @spec set_interrupt_persistence(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_interrupt_persistence(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.PERS.address(), <<byte>>])
  end

  def set_interrupt_persistence(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_interrupt_persistence(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.PERS.address(), new_data])
  end

  ## 0x8D CONFIG1 Read/Write Configuration register one

  @spec get_config1(Transport.t()) :: {:ok, Register.CONFIG1.t()}
  def get_config1(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.CONFIG1.address()], 1)
    {:ok, Register.CONFIG1.parse(data)}
  end

  @spec set_config1(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_config1(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.CONFIG1.address(), <<byte>>])
  end

  def set_config1(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_config1(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.CONFIG1.address(), new_data])
  end

  ## 0x8E PPULSE Read/Write Proximity pulse count and length

  @spec get_proximity_pulse(Transport.t()) :: {:ok, Register.PPULSE.t()}
  def get_proximity_pulse(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.PPULSE.address()], 1)
    {:ok, Register.PPULSE.parse(data)}
  end

  @spec set_proximity_pulse(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_proximity_pulse(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.PPULSE.address(), <<byte>>])
  end

  def set_proximity_pulse(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_proximity_pulse(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.PPULSE.address(), new_data])
  end

  ## 0x8F CONTROL Read/Write Gain control

  @spec get_control(Transport.t()) :: {:ok, Register.CONTROL.t()}
  def get_control(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.CONTROL.address()], 1)
    {:ok, Register.CONTROL.parse(data)}
  end

  @spec set_control(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_control(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.CONTROL.address(), <<byte>>])
  end

  def set_control(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_control(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.CONTROL.address(), new_data])
  end

  ## 0x90 CONFIG2 Read/Write Configuration register two

  @spec get_config2(Transport.t()) :: {:ok, Register.CONFIG2.t()}
  def get_config2(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.CONFIG2.address()], 1)
    {:ok, Register.CONFIG2.parse(data)}
  end

  @spec set_config2(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_config2(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.CONFIG2.address(), <<byte>>])
  end

  def set_config2(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_config2(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.CONFIG2.address(), new_data])
  end

  ## 0x93 STATUS Read-only Device status

  @spec status(Transport.t()) :: {:ok, Register.STATUS.t()}
  def status(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.STATUS.address()], 1)
    {:ok, Register.STATUS.parse(data)}
  end

  ## 0x94 CDATAL Read-only Color data (2 bytes)

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

  ## 0x9D POFFSET_UR Read/Write Proximity offset for photodiodes (2 bytes)

  @spec get_proximity_offset(Transport.t()) :: {:ok, Register.POFFSET_UR.t()}
  def get_proximity_offset(%Transport{} = i2c) do
    {:ok, <<_::16>> = data} = i2c.write_read_fn.([Register.POFFSET_UR.address()], 2)
    {:ok, Register.POFFSET_UR.parse(data)}
  end

  @spec set_proximity_offset(Transport.t(), <<_::16>> | Enum.t()) :: :ok
  def set_proximity_offset(%Transport{} = i2c, <<_::16>> = data) do
    i2c.write_fn.([Register.POFFSET_UR.address(), data])
  end

  def set_proximity_offset(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_proximity_offset(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.POFFSET_UR.address(), new_data])
  end

  ## 0x9F CONFIG3 Read/Write Configuration register three

  @spec get_config3(Transport.t()) :: {:ok, Register.CONFIG3.t()}
  def get_config3(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.CONFIG3.address()], 1)
    {:ok, Register.CONFIG3.parse(data)}
  end

  @spec set_config3(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_config3(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.CONFIG3.address(), <<byte>>])
  end

  def set_config3(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_config3(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.CONFIG3.address(), new_data])
  end

  ## 0xA0 GPENTH Read/Write Gesture proximity enter/exit threshold

  @spec get_gesture_proximity_threshold(Transport.t()) :: {:ok, Register.GPENTH.t()}
  def get_gesture_proximity_threshold(%Transport{} = i2c) do
    {:ok, <<_::16>> = data} = i2c.write_read_fn.([Register.GPENTH.address()], 2)
    {:ok, Register.GPENTH.parse(data)}
  end

  @spec set_gesture_proximity_threshold(Transport.t(), <<_::16>> | Enum.t()) :: :ok
  def set_gesture_proximity_threshold(%Transport{} = i2c, <<enter_th, exit_th>>) do
    i2c.write_fn.([Register.GPENTH.address(), <<enter_th, exit_th>>])
  end

  def set_gesture_proximity_threshold(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_proximity_threshold(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.GPENTH.address(), new_data])
  end

  ## 0xA2 GCONF1 Read/Write Gesture configuration one

  @spec get_gesture_conf1(Transport.t()) :: {:ok, Register.GCONF1.t()}
  def get_gesture_conf1(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GCONF1.address()], 1)
    {:ok, Register.GCONF1.parse(data)}
  end

  @spec set_gesture_conf1(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_gesture_conf1(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GCONF1.address(), <<byte>>])
  end

  def set_gesture_conf1(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_conf1(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
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
    i2c.write_fn.([Register.GCONF2.address(), <<byte>>])
  end

  def set_gesture_conf2(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_conf2(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.GCONF2.address(), new_data])
  end

  ## 0xA4 GOFFSET_U R/W Gesture UP offset register
  ## 0xA5 GOFFSET_D R/W Gesture DOWN offset register
  ## 0xA7 GOFFSET_L R/W Gesture LEFT offset register
  ## 0xA9 GOFFSET_R R/W Gesture RIGHT offset register

  @spec get_gesture_offset(Transport.t()) ::
          {:ok, %{down: -127..127, left: -127..127, right: -127..127, up: -127..127}}
  def get_gesture_offset(%Transport{} = i2c) do
    {:ok, data_u} = i2c.write_read_fn.([Register.GOFFSET_U.address()], 1)
    {:ok, data_d} = i2c.write_read_fn.([Register.GOFFSET_D.address()], 1)
    {:ok, data_l} = i2c.write_read_fn.([Register.GOFFSET_L.address()], 1)
    {:ok, data_r} = i2c.write_read_fn.([Register.GOFFSET_R.address()], 1)

    {:ok,
     %{
       up: Register.GOFFSET_U.parse(data_u),
       down: Register.GOFFSET_D.parse(data_d),
       left: Register.GOFFSET_L.parse(data_l),
       right: Register.GOFFSET_R.parse(data_r)
     }}
  end

  @spec set_gesture_offset(Transport.t(), Enum.t()) :: :ok
  def set_gesture_offset(%Transport{} = i2c, opts) do
    if data_up = opts[:up] do
      :ok = i2c.write_fn.([Register.GOFFSET_U.address(), Register.GOFFSET_U.to_binary(data_up)])
    end

    if data_down = opts[:down] do
      :ok = i2c.write_fn.([Register.GOFFSET_D.address(), Register.GOFFSET_D.to_binary(data_down)])
    end

    if data_left = opts[:left] do
      :ok = i2c.write_fn.([Register.GOFFSET_L.address(), Register.GOFFSET_L.to_binary(data_left)])
    end

    if data_right = opts[:right] do
      :ok =
        i2c.write_fn.([Register.GOFFSET_R.address(), Register.GOFFSET_R.to_binary(data_right)])
    end

    :ok
  end

  ## 0xA6 GPULSE Read/Write Gesture pulse count and length

  @spec get_gesture_pulse(Transport.t()) :: {:ok, Register.GPULSE.t()}
  def get_gesture_pulse(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GPULSE.address()], 1)
    {:ok, Register.GPULSE.parse(data)}
  end

  @spec set_gesture_pulse(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_gesture_pulse(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GPULSE.address(), <<byte>>])
  end

  def set_gesture_pulse(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_pulse(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.GPULSE.address(), new_data])
  end

  ## 0xAA GCONF3 R/W Gesture configuration three

  @spec get_gesture_conf3(Transport.t()) :: {:ok, Register.GCONF3.t()}
  def get_gesture_conf3(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GCONF3.address()], 1)
    {:ok, Register.GCONF3.parse(data)}
  end

  def set_gesture_conf3(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_conf3(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
    i2c.write_fn.([Register.GCONF3.address(), new_data])
  end

  ## 0xAB GCONF4 Read/Write Gesture configuration four

  @spec get_gesture_conf4(Transport.t()) :: {:ok, Register.GCONF4.t()}
  def get_gesture_conf4(%Transport{} = i2c) do
    {:ok, data} = i2c.write_read_fn.([Register.GCONF4.address()], 1)
    {:ok, Register.GCONF4.parse(data)}
  end

  @spec set_gesture_conf4(Transport.t(), <<_::8>> | Enum.t()) :: :ok
  def set_gesture_conf4(%Transport{} = i2c, <<byte>>) do
    i2c.write_fn.([Register.GCONF4.address(), <<byte>>])
  end

  def set_gesture_conf4(%Transport{} = i2c, opts) do
    {:ok, parsed_data} = get_gesture_conf4(i2c)
    new_data = parsed_data |> Register.set_bits(opts) |> Register.to_binary()
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

  ## 0xE5 PICLEAR W Proximity interrupt clear

  @spec clear_proximity_interrupt(Transport.t()) :: :ok
  def clear_proximity_interrupt(%Transport{} = i2c) do
    i2c.write_fn.([Register.PICLEAR.address()])
  end

  ## 0xE6 CICLEAR W ALS clear channel interrupt clear

  @spec clear_als_clear_channel_interrupt(Transport.t()) :: :ok
  def clear_als_clear_channel_interrupt(%Transport{} = i2c) do
    i2c.write_fn.([Register.PICLEAR.address()])
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
