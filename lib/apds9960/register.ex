defmodule APDS9960.Register do
  @moduledoc false

  @doc """
  Sets only specified bit values in a register value struct.
  """
  @spec set_bits(struct, Enum.t()) :: struct
  def set_bits(parsed_data, opts) when is_struct(parsed_data) do
    struct!(parsed_data, opts)
  end

  @doc """
  Converts a register value struct to binary.
  """
  @spec to_binary(struct) :: binary
  def to_binary(parsed_data) when is_struct(parsed_data) do
    parsed_data
    |> Map.from_struct()
    |> parsed_data.__struct__.to_binary()
  end

  # 0x80 ENABLE Read/Write Enable states and interrupts 0x00
  defmodule ENABLE do
    @moduledoc false
    def address, do: 0x80

    use TypedStruct

    typedstruct do
      field(:gesture, 0 | 1, default: 0)
      field(:proximity_interrupt, 0 | 1, default: 0)
      field(:als_interrupt, 0 | 1, default: 0)
      field(:wait, 0 | 1, default: 0)
      field(:proximity, 0 | 1, default: 0)
      field(:als, 0 | 1, default: 0)
      field(:power, 0 | 1, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b6 = d.gesture
      b5 = d.proximity_interrupt
      b4 = d.als_interrupt
      b3 = d.wait
      b2 = d.proximity
      b1 = d.als
      b0 = d.power

      <<0::1, b6::1, b5::1, b4::1, b3::1, b2::1, b1::1, b0::1>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<0::1, b6::1, b5::1, b4::1, b3::1, b2::1, b1::1, b0::1>>) do
      %__MODULE__{
        gesture: b6,
        proximity_interrupt: b5,
        als_interrupt: b4,
        wait: b3,
        proximity: b2,
        als: b1,
        power: b0
      }
    end
  end

  # 0x81 ATIME Read/Write ADC integration time
  defmodule ATIME do
    @moduledoc false
    def address, do: 0x81
  end

  # 0x83 WTIME Read/Write Wait time (non-gesture)
  defmodule WTIME do
    @moduledoc false
    def address, do: 0x83
  end

  # 0x84 AILTL Read/Write ALS interrupt low/high thresholds
  defmodule AILTL do
    @moduledoc false
    def address, do: 0x84
  end

  # 0x89 PILT Read/Write Proximity interrupt low/high thresholds
  defmodule PILT do
    @moduledoc false
    def address, do: 0x89

    use TypedStruct

    typedstruct do
      field(:low, byte, default: 0)
      field(:high, byte, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::16>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      <<d.low, d.high>>
    end

    @spec parse(<<_::16>>) :: t()
    def parse(<<low, high>>) do
      %__MODULE__{low: low, high: high}
    end
  end

  # 0x8C PERS Read/Write Interrupt persistence filters (non-gesture)
  defmodule PERS do
    @moduledoc false
    def address, do: 0x8C

    use TypedStruct

    typedstruct do
      field(:proximity, 0..15, default: 0)
      field(:als, 0..15, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b74 = d.proximity
      b30 = d.als

      <<b74::4, b30::4>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<b74::4, b30::4>>) do
      %__MODULE__{
        proximity: b74,
        als: b30
      }
    end
  end

  # 0x8D CONFIG1 Read/Write Configuration register one
  defmodule CONFIG1 do
    @moduledoc false
    def address, do: 0x8D
  end

  # 0x8E PPULSE Read/Write Proximity pulse count and length
  defmodule PPULSE do
    @moduledoc false
    def address, do: 0x8E

    use TypedStruct

    typedstruct do
      field(:proximity_pulse_length, 0..3, default: 1)
      field(:proximity_pulse_count, 0..63, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b76 = d.proximity_pulse_length
      b50 = d.proximity_pulse_count

      <<b76::2, b50::6>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<b76::2, b50::6>>) do
      %__MODULE__{
        proximity_pulse_length: b76,
        proximity_pulse_count: b50
      }
    end
  end

  # 0x8F CONTROL Read/Write Gain control
  defmodule CONTROL do
    @moduledoc false
    def address, do: 0x8F

    use TypedStruct

    typedstruct do
      field(:led_drive_strength, 0..3, default: 0)
      field(:proximity_gain, 0..3, default: 0)
      field(:als_and_color_gain, 0..3, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b76 = d.led_drive_strength
      b32 = d.proximity_gain
      b10 = d.als_and_color_gain

      <<b76::2, 0::2, b32::2, b10::2>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<b76::2, 0::2, b32::2, b10::2>>) do
      %__MODULE__{
        led_drive_strength: b76,
        proximity_gain: b32,
        als_and_color_gain: b10
      }
    end
  end

  # 0x90 CONFIG2 Read/Write Configuration register two
  defmodule CONFIG2 do
    @moduledoc false
    def address, do: 0x90

    use TypedStruct

    typedstruct do
      field(:proximity_saturation_interrupt, 0 | 1, default: 0)
      field(:als_saturation_interrupt, 0 | 1, default: 0)
      field(:led_boost, 0..3, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b7 = d.proximity_saturation_interrupt
      b6 = d.als_saturation_interrupt
      b54 = d.led_boost

      <<b7::1, b6::1, b54::2, 0::3, 1::1>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<b7::1, b6::1, b54::2, _::3, _::1>>) do
      %__MODULE__{
        proximity_saturation_interrupt: b7,
        als_saturation_interrupt: b6,
        led_boost: b54
      }
    end
  end

  # 0x92 ID Read-only Device ID
  defmodule ID do
    @moduledoc false
    def address, do: 0x92
  end

  # 0x93 STATUS Read-only Device status 0x00
  defmodule STATUS do
    @moduledoc false
    def address, do: 0x93

    use TypedStruct

    typedstruct do
      field(:clear_photo_diode_saturation, 0 | 1, default: 0)
      field(:proximity_or_gesture_saturation, 0 | 1, default: 0)
      field(:proximity_interrupt, 0 | 1, default: 0)
      field(:als_interrupt, 0 | 1, default: 0)
      field(:gesture_interrupt, 0 | 1, default: 0)
      field(:proximity_valid, 0 | 1, default: 0)
      field(:als_valid, 0 | 1, default: 0)
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<b7::1, b6::1, b5::1, b4::1, _::1, b2::1, b1::1, b0::1>>) do
      %__MODULE__{
        clear_photo_diode_saturation: b7,
        proximity_or_gesture_saturation: b6,
        proximity_interrupt: b5,
        als_interrupt: b4,
        gesture_interrupt: b2,
        proximity_valid: b1,
        als_valid: b0
      }
    end
  end

  # 0x94 CDATAL Read-only RGBC data
  defmodule CDATAL do
    @moduledoc false
    def address, do: 0x94

    use TypedStruct

    typedstruct do
      field(:red, 0..0xFFFF, enforce: true)
      field(:green, 0..0xFFFF, enforce: true)
      field(:blue, 0..0xFFFF, enforce: true)
      field(:clear, 0..0xFFFF, enforce: true)
    end

    @spec parse(<<_::64>>) :: t()
    def parse(<<clear::little-16, red::little-16, green::little-16, blue::little-16>>) do
      %__MODULE__{red: red, green: green, blue: blue, clear: clear}
    end
  end

  # 0x9C PDATA Read-only Proximity data
  defmodule PDATA do
    @moduledoc false
    def address, do: 0x9C
  end

  # 0x9D POFFSET_UR Read/Write Proximity offset for photodiodes
  defmodule POFFSET_UR do
    @moduledoc false
    def address, do: 0x9D

    use TypedStruct

    typedstruct do
      field(:proximity_offset_up_right, -127..127, default: 0)
      field(:proximity_offset_down_left, -127..127, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::16>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      sign_ur = sign(d.proximity_offset_up_right)
      bits_ur = abs(d.proximity_offset_up_right)
      sign_dl = sign(d.proximity_offset_down_left)
      bits_dl = abs(d.proximity_offset_down_left)

      <<sign_ur::1, bits_ur::7, sign_dl::1, bits_dl::7>>
    end

    @spec parse(<<_::16>>) :: t()
    def parse(<<data_ur, data_dl>>) do
      %__MODULE__{
        proximity_offset_up_right: offset_correction_factor(<<data_ur>>),
        proximity_offset_down_left: offset_correction_factor(<<data_dl>>)
      }
    end

    defp offset_correction_factor(<<sign::1, factor::7>>) when sign == 1, do: -factor
    defp offset_correction_factor(<<_::1, factor::7>>), do: factor

    defp sign(value) when value < 0, do: 1
    defp sign(_), do: 0
  end

  # 0x9F CONFIG3 Read/Write Configuration register three
  defmodule CONFIG3 do
    @moduledoc false
    def address, do: 0x9F

    use TypedStruct

    typedstruct do
      field(:proximity_gain_compensation, 0 | 1, default: 0)
      field(:sleep_after_interrupt, 0 | 1, default: 0)
      field(:proximity_mask, 0b0000..0b1110, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b5 = proximity_gain_compensation(d.proximity_mask)
      b4 = d.sleep_after_interrupt
      b30 = d.proximity_mask

      <<0::2, b5::1, b4::1, b30::4>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<_::2, b5::1, b4::1, b30::4>>) do
      %__MODULE__{
        proximity_gain_compensation: b5,
        sleep_after_interrupt: b4,
        proximity_mask: b30
      }
    end

    defp proximity_gain_compensation(0b0111), do: 1
    defp proximity_gain_compensation(0b1011), do: 1
    defp proximity_gain_compensation(0b1101), do: 1
    defp proximity_gain_compensation(0b1110), do: 1
    defp proximity_gain_compensation(0b0101), do: 1
    defp proximity_gain_compensation(0b1010), do: 1
    defp proximity_gain_compensation(_proximity_mask), do: 0
  end

  # 0xA0 GPENTH Read/Write Gesture proximity enter threshold
  defmodule GPENTH do
    @moduledoc false
    def address, do: 0xA0
  end

  # 0xA1 GEXTH Read/Write Gesture exit threshold
  defmodule GEXTH do
    @moduledoc false
    def address, do: 0xA1
  end

  # 0xA2 GCONF1 Read/Write Gesture configuration one
  defmodule GCONF1 do
    @moduledoc false
    def address, do: 0xA2

    use TypedStruct

    typedstruct do
      field(:gesture_fifo_threshold, 0..3, default: 0)
      field(:gesture_exit_mask, 0x0000..0x1111, default: 0)
      field(:gesture_exit_persistence, 0..3, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b76 = d.gesture_fifo_threshold
      b52 = d.gesture_exit_mask
      b10 = d.gesture_exit_persistence

      <<b76::2, b52::4, b10::2>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<b76::2, b52::4, b10::2>>) do
      %__MODULE__{
        gesture_fifo_threshold: b76,
        gesture_exit_mask: b52,
        gesture_exit_persistence: b10
      }
    end
  end

  # 0xA3 GCONF2 Read/Write Gesture configuration two
  defmodule GCONF2 do
    @moduledoc false
    def address, do: 0xA3

    use TypedStruct

    typedstruct do
      field(:gesture_gain, 0..3, default: 0)
      field(:gesture_led_drive_strength, 0..3, default: 0)
      field(:gesture_wait_time, 0..7, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b65 = d.gesture_gain
      b43 = d.gesture_led_drive_strength
      b20 = d.gesture_wait_time

      <<0::1, b65::2, b43::2, b20::3>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<0::1, b65::2, b43::2, b20::3>>) do
      %__MODULE__{
        gesture_gain: b65,
        gesture_led_drive_strength: b43,
        gesture_wait_time: b20
      }
    end
  end

  # 0xA4 GOFFSET_U Read/Write Gesture UP offset register
  defmodule GOFFSET_U do
    @moduledoc false
    def address, do: 0xA4
  end

  # 0xA5 GOFFSET_D Read/Write Gesture DOWN offset register
  defmodule GOFFSET_D do
    @moduledoc false
    def address, do: 0xA5
  end

  # 0xA7 GOFFSET_L Read/Write Gesture LEFT offset register
  defmodule GOFFSET_L do
    @moduledoc false
    def address, do: 0xA7
  end

  # 0xA9 GOFFSET_R Read/Write Gesture RIGHT offset register
  defmodule GOFFSET_R do
    @moduledoc false
    @spec address :: 169
    def address, do: 0xA9
  end

  # 0xA6 GPULSE Read/Write Gesture pulse count and length
  defmodule GPULSE do
    @moduledoc false
    def address, do: 0xA6

    use TypedStruct

    typedstruct do
      field(:gesture_pulse_length, 0..3, default: 0)
      field(:gesture_pulse_count, 0..63, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b76 = d.gesture_pulse_length
      b50 = d.gesture_pulse_count

      <<b76::2, b50::6>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<b76::2, b50::6>>) do
      %__MODULE__{
        gesture_pulse_length: b76,
        gesture_pulse_count: b50
      }
    end
  end

  # 0xAA GCONF3 Read/Write Gesture configuration three
  defmodule GCONF3 do
    @moduledoc false
    def address, do: 0xAA
  end

  # 0xAB GCONF4 Read/Write Gesture configuration four
  defmodule GCONF4 do
    @moduledoc false
    def address, do: 0xAB

    use TypedStruct

    typedstruct do
      field(:gesture_interrupt, 0 | 1, default: 0)
      field(:gesture_mode, 0 | 1, default: 0)
    end

    @spec to_binary(Enum.t()) :: <<_::8>>
    def to_binary(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b1 = d.gesture_interrupt
      b0 = d.gesture_mode

      <<0::6, b1::1, b0::1>>
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<0::6, b1::1, b0::1>>) do
      %__MODULE__{
        gesture_interrupt: b1,
        gesture_mode: b0
      }
    end
  end

  # 0xAE GFLVL Read-only Gesture FIFO level
  defmodule GFLVL do
    @moduledoc false
    def address, do: 0xAE
  end

  # 0xAF GSTATUS Read-only Gesture status
  defmodule GSTATUS do
    @moduledoc false
    def address, do: 0xAF

    use TypedStruct

    typedstruct do
      field(:gesture_fifo_overflow, 0 | 1, default: 0)
      field(:gesture_valid, 0 | 1, default: 0)
    end

    @spec parse(<<_::8>>) :: t()
    def parse(<<0::6, b1::1, b0::1>>) do
      %__MODULE__{
        gesture_fifo_overflow: b1,
        gesture_valid: b0
      }
    end
  end

  # 0xE4 IFORCE W Force interrupt
  defmodule IFORCE do
    @moduledoc false
    def address, do: 0xE4
  end

  # 0xE5 PICLEAR W Proximity interrupt clear
  defmodule PICLEAR do
    @moduledoc false
    def address, do: 0xE5
  end

  # 0xE6 CICLEAR W ALS clear channel interrupt clear
  defmodule CICLEAR do
    @moduledoc false
    def address, do: 0xE6
  end

  # 0xE7 AICLEAR W All non-gesture interrupts clear
  defmodule AICLEAR do
    @moduledoc false
    def address, do: 0xE7
  end

  # 0xFC GFIFO_U Read-only Gesture FIFO UP/DOWN/LEFT/RIGHT values
  defmodule GFIFO_U do
    @moduledoc false
    def address, do: 0xFC

    @spec parse(binary) :: [{byte, byte, byte, byte}]
    def parse(data) do
      for <<up, down, left, right <- data>>, do: {up, down, left, right}
    end
  end
end
