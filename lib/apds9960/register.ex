defmodule APDS9960.Register do
  @moduledoc false

  @doc """
  Sets only specified bit values in a register value struct.
  """
  @spec set_bits(struct(), Enum.t()) :: struct()
  def set_bits(parsed_data, opts) when is_struct(parsed_data) do
    struct!(parsed_data, opts)
  end

  @doc """
  Converts a register value struct to binary.
  """
  @spec data(struct) :: binary
  def data(parsed_data) when is_struct(parsed_data) do
    parsed_data
    |> Map.from_struct()
    |> parsed_data.__struct__.data()
  end

  defmodule RAM do
    @moduledoc false
    def address, do: 0x00
  end

  defmodule ENABLE do
    @moduledoc false
    def address, do: 0x80

    # Before enabling Gesture, Proximity, or ALS, all of the bits associated with control of the
    # desired function must be set. Changing control register values while operating may result in
    # invalid results.
    defstruct gesture: 0,
              proximity_interrupt: 0,
              als_interrupt: 0,
              wait: 0,
              proximity: 0,
              als: 0,
              power: 0

    @spec data(Enum.t()) :: <<_::8>>
    def data(opts \\ []) do
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

    @spec parse(<<_::8>>) :: %__MODULE__{}
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

  defmodule ATIME do
    @moduledoc false
    def address, do: 0x81
  end

  defmodule WTIME do
    @moduledoc false
    def address, do: 0x83
  end

  defmodule AILTIL do
    @moduledoc false
    def address, do: 0x84
  end

  defmodule AILTH do
    @moduledoc false
    def address, do: 0x85
  end

  defmodule AIHTL do
    @moduledoc false
    def address, do: 0x86
  end

  defmodule AIHTH do
    @moduledoc false
    def address, do: 0x87
  end

  defmodule PILT do
    @moduledoc false
    def address, do: 0x89
  end

  defmodule PIHT do
    @moduledoc false
    def address, do: 0x8B
  end

  defmodule PERS do
    @moduledoc false
    def address, do: 0x8C

    defstruct proximity: 0,
              als: 0

    @spec data(Enum.t()) :: <<_::8>>
    def data(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b74 = d.proximity
      b30 = d.als

      <<b74::4, b30::4>>
    end

    @spec parse(<<_::8>>) :: %__MODULE__{}
    def parse(<<b74::4, b30::4>>) do
      %__MODULE__{
        proximity: b74,
        als: b30
      }
    end
  end

  defmodule CONFIG1 do
    @moduledoc false
    def address, do: 0x8D
  end

  defmodule PPULSE do
    @moduledoc false
    def address, do: 0x8E
  end

  defmodule CONTROL do
    @moduledoc false
    def address, do: 0x8F

    defstruct led_drive_strength: 0,
              proximity_gain: 0,
              als_and_color_gain: 0

    @spec data(Enum.t()) :: <<_::8>>
    def data(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b76 = d.led_drive_strength
      b32 = d.proximity_gain
      b10 = d.als_and_color_gain

      <<b76::2, 0::2, b32::2, b10::2>>
    end

    @spec parse(<<_::8>>) :: %__MODULE__{}
    def parse(<<b76::2, 0::2, b32::2, b10::2>>) do
      %__MODULE__{
        led_drive_strength: b76,
        proximity_gain: b32,
        als_and_color_gain: b10
      }
    end
  end

  defmodule CONFIG2 do
    @moduledoc false
    def address, do: 0x90
  end

  defmodule ID do
    @moduledoc false
    def address, do: 0x92
  end

  defmodule STATUS do
    @moduledoc false
    def address, do: 0x93

    defstruct clear_photo_diode_saturation: 0,
              proximity_or_gesture_saturation: 0,
              proximity_interrupt: 0,
              als_interrupt: 0,
              gesture_interrupt: 0,
              proximity_valid: 0,
              als_valid: 0

    @spec parse(<<_::8>>) :: %__MODULE__{}
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

  defmodule CDATAL do
    @moduledoc false
    def address, do: 0x94

    defstruct red: 0,
              green: 0,
              blue: 0,
              clear: 0

    @spec parse(<<_::64>>) :: %__MODULE__{}
    def parse(<<clear::little-16, red::little-16, green::little-16, blue::little-16>>) do
      %__MODULE__{
        red: red,
        green: green,
        blue: blue,
        clear: clear
      }
    end
  end

  defmodule CDATAH do
    @moduledoc false
    def address, do: 0x95
  end

  defmodule RDATAL do
    @moduledoc false
    def address, do: 0x96
  end

  defmodule RDATAH do
    @moduledoc false
    def address, do: 0x97
  end

  defmodule GDATAL do
    @moduledoc false
    def address, do: 0x98
  end

  defmodule GDATAH do
    @moduledoc false
    def address, do: 0x99
  end

  defmodule BDATAL do
    @moduledoc false
    def address, do: 0x9A
  end

  defmodule BDATAH do
    @moduledoc false
    def address, do: 0x9B
  end

  defmodule PDATA do
    @moduledoc false
    def address, do: 0x9C
  end

  defmodule POFFSET_UR do
    @moduledoc false
    def address, do: 0x9D
  end

  defmodule POFFSET_DL do
    @moduledoc false
    def address, do: 0x9E
  end

  defmodule CONFIG3 do
    @moduledoc false
    def address, do: 0x9F
  end

  defmodule GPENTH do
    @moduledoc false
    def address, do: 0xA0
  end

  defmodule GEXTH do
    @moduledoc false
    def address, do: 0xA1
  end

  defmodule GCONF1 do
    @moduledoc false
    def address, do: 0xA2

    defstruct gesture_fifo_threshold: 0,
              gesture_exit_mask: 0,
              gesture_exit_persistence: 0

    @spec data(Enum.t()) :: <<_::8>>
    def data(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b76 = d.gesture_fifo_threshold
      b52 = d.gesture_exit_mask
      b10 = d.gesture_exit_persistence

      <<b76::2, b52::4, b10::2>>
    end

    @spec parse(<<_::8>>) :: %__MODULE__{}
    def parse(<<b76::2, b52::4, b10::2>>) do
      %__MODULE__{
        gesture_fifo_threshold: b76,
        gesture_exit_mask: b52,
        gesture_exit_persistence: b10
      }
    end
  end

  defmodule GCONF2 do
    @moduledoc false
    def address, do: 0xA3

    defstruct gesture_gain: 0,
              gesture_led_drive_strength: 0,
              gesture_wait_time: 0

    @spec data(Enum.t()) :: <<_::8>>
    def data(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b65 = d.gesture_gain
      b43 = d.gesture_led_drive_strength
      b20 = d.gesture_wait_time

      <<0::1, b65::2, b43::2, b20::3>>
    end

    @spec parse(<<_::8>>) :: %__MODULE__{}
    def parse(<<0::1, b65::2, b43::2, b20::3>>) do
      %__MODULE__{
        gesture_gain: b65,
        gesture_led_drive_strength: b43,
        gesture_wait_time: b20
      }
    end
  end

  defmodule GOFFSET_U do
    @moduledoc false
    def address, do: 0xA4
  end

  defmodule GOFFSET_D do
    @moduledoc false
    def address, do: 0xA5
  end

  defmodule GOFFSET_L do
    @moduledoc false
    def address, do: 0xA7
  end

  defmodule GOFFSET_R do
    @moduledoc false
    def address, do: 0xA9
  end

  defmodule GPULSE do
    @moduledoc false
    def address, do: 0xA6

    defstruct gesture_pulse_length: 0,
              gesture_pulse_count: 0

    @spec data(Enum.t()) :: <<_::8>>
    def data(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b76 = d.gesture_pulse_length
      b50 = d.gesture_pulse_count

      <<b76::2, b50::6>>
    end

    @spec parse(<<_::8>>) :: %__MODULE__{}
    def parse(<<b76::2, b50::6>>) do
      %__MODULE__{
        gesture_pulse_length: b76,
        gesture_pulse_count: b50
      }
    end
  end

  defmodule GCONF3 do
    @moduledoc false
    def address, do: 0xAA
  end

  defmodule GCONF4 do
    @moduledoc false
    def address, do: 0xAB

    defstruct gesture_interrupt: 0,
              gesture_mode: 0

    @spec data(Enum.t()) :: <<_::8>>
    def data(opts \\ []) do
      d = struct!(__MODULE__, opts)

      b1 = d.gesture_interrupt
      b0 = d.gesture_mode

      <<0::6, b1::1, b0::1>>
    end

    @spec parse(<<_::8>>) :: %__MODULE__{}
    def parse(<<0::6, b1::1, b0::1>>) do
      %__MODULE__{
        gesture_interrupt: b1,
        gesture_mode: b0
      }
    end
  end

  defmodule GFLVL do
    @moduledoc false
    def address, do: 0xAE
  end

  defmodule GSTATUS do
    @moduledoc false
    def address, do: 0xAF

    defstruct gesture_fifo_overflow: 0,
              gesture_valid: 0

    @spec parse(<<_::8>>) :: %__MODULE__{}
    def parse(<<0::6, b1::1, b0::1>>) do
      %__MODULE__{
        gesture_fifo_overflow: b1,
        gesture_valid: b0
      }
    end
  end

  defmodule IFORCE do
    @moduledoc false
    def address, do: 0xE4
  end

  defmodule PICLEAR do
    @moduledoc false
    def address, do: 0xE5
  end

  defmodule CICLEAR do
    @moduledoc false
    def address, do: 0xE6
  end

  defmodule AICLEAR do
    @moduledoc false
    def address, do: 0xE7
  end

  defmodule GFIFO_U do
    @moduledoc false
    def address, do: 0xFC
  end

  defmodule GFIFO_D do
    @moduledoc false
    def address, do: 0xFD
  end

  defmodule GFIFO_L do
    @moduledoc false
    def address, do: 0xFE
  end

  defmodule GFIFO_R do
    @moduledoc false
    def address, do: 0xFF
  end
end
