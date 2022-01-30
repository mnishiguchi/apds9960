# APDS9960

[![Hex version](https://img.shields.io/hexpm/v/apds9960.svg 'Hex version')](https://hex.pm/packages/apds9960)
[![API docs](https://img.shields.io/hexpm/v/apds9960.svg?label=docs 'API docs')](https://hexdocs.pm/apds9960)
[![CI](https://github.com/mnishiguchi/apds9960/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/apds9960/actions/workflows/ci.yml)

Use `APDS9960` color, proximity and gesture sensor in Elixir.

## Installation

Add apds9960 to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:apds9960, "~> 0.1"}
  ]
end
```

## Usage

### Proximity detection

The proximity value ranges from 0 to 255, where the higher the number the closer an object is to the sensor.

**Initialize the sensor**

```elixir
sensor = APDS9960.init()
```

**Enable the proximity engine**

```elixir
APDS9960.enable(sensor, :proximity)
```

**Measure proximity**

```elixir
APDS9960.proximity(sensor)
```

### RGB Color Sensing

The results are 16-bit values from 0 to 65535, where 0 means the minimum amount of color and 65535 is the maximum amount of color.

**Initialize the sensor**

```elixir
sensor = APDS9960.init()
```

**Enable the color engine**

```elixir
APDS9960.enable(sensor, :color)
```

**Retrieve the red, green, blue and clear color values**

```elixir
APDS9960.color(sensor)
# %{blue: 52, clear: 235, green: 73, red: 128}
```

### Gesture detection

**Initialize the sensor**

```elixir
sensor = APDS9960.init()
```

**Enable the proximity and gesture engines**

```elixir
APDS9960.enable(sensor, :proximity)
APDS9960.enable(sensor, :gesture)
```

**Detect gesture direction**

```elixir
APDS9960.gesture(sensor, timeout: 5000)
```

For more information, see [API reference](https://hexdocs.pm/apds9960/api-reference.html).
