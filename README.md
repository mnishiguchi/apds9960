# APDS9960

[![Hex version](https://img.shields.io/hexpm/v/apds9960.svg 'Hex version')](https://hex.pm/packages/apds9960)
[![API docs](https://img.shields.io/hexpm/v/apds9960.svg?label=docs 'API docs')](https://hexdocs.pm/apds9960)
[![CI](https://github.com/mnishiguchi/apds9960/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/apds9960/actions/workflows/ci.yml)

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
sensor = APDS9960.init()

# To get a proximity result, first enable the proximity engine
APDS9960.enable(sensor, :proximity)

# Measure proximity
APDS9960.proximity(sensor)
```

### RGB Color Sensing

```elixir
# Initialize the sensor
sensor = APDS9960.init()

# To get a color measurement, first enable the color engine
APDS9960.enable(sensor, :color)

# Retrieve the red, green, blue and clear color values as 16-bit values for each
APDS9960.color(sensor)
```

### Gesture detection

TODO


For more information, see [API reference](https://hexdocs.pm/apds9960/api-reference.html).
