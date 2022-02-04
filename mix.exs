defmodule APDS9960.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/mnishiguchi/apds9960"

  def project do
    [
      app: :apds9960,
      version: @version,
      description: "Use the digital Color, proximity and gesture sensor `APDS9960` in Elixir.",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      package: package(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_i2c, "~> 1.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28", only: :docs, runtime: false},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:typed_struct, "~> 0.2.1"}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp package do
    %{
      files: [
        "lib",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Data sheet" =>
          "https://cdn-learn.adafruit.com/assets/assets/000/045/848/original/Avago-APDS-9960-datasheet.pdf"
      }
    }
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      format: ["format", "credo --strict"]
    ]
  end
end
