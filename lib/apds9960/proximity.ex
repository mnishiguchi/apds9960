defmodule APDS9960.Proximity do
  @moduledoc false

  alias APDS9960.{Comm, Sensor}

  @spec read_proximity(Sensor.t(), Enum.t()) :: byte
  def read_proximity(%Sensor{} = sensor, _opts \\ []) do
    {:ok, <<byte>>} = Comm.proximity_data(sensor.transport)
    byte
  end
end
