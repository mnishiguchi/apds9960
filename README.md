# APDS9960

Use the digital Color, proximity and gesture sensor `APDS9960` in Elixir.
## Installation

Add apds9960 to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:apds9960, "~> 0.1.0"}
  ]
end
```

## Usage

### Proximity detection

The proximity value is a number from 0 to 255 where the higher the number the closer an object is to the sensor.

```elixir
# Initialize the sensor
sensor = APDS9960.new

# To get a proximity result, first enable the proximity engine.
APDS9960.enable(sensor, :proximity)

# Measure proximity
APDS9960.proximity(sensor)
```

### RGB Color Sensing

TODO

### Gesture detection

TODO


For more information, see [API reference](https://hexdocs.pm/apds9960/api-reference.html).
