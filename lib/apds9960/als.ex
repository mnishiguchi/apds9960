defmodule APDS9960.ALS do
  @moduledoc false

  alias APDS9960.Comm

  @spec read_proximity(APDS9960.t(), Enum.t()) :: byte
  def read_proximity(%APDS9960{} = sensor, _opts \\ []) do
    {:ok, <<byte>>} = Comm.proximity_data(sensor.transport)
    byte
  end
end
