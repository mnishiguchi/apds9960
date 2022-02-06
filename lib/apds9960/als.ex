defmodule APDS9960.ALS do
  @moduledoc false

  alias APDS9960.{Comm, Sensor}

  @spec read_color(Sensor.t(), Enum.t()) :: %{
          red: 0..0xFFFF,
          green: 0..0xFFFF,
          blue: 0..0xFFFF,
          clear: 0..0xFFFF
        }
  def read_color(%Sensor{} = sensor, _opts \\ []) do
    {:ok, struct} = Comm.color_data(sensor.transport)
    Map.from_struct(struct)
  end
end
