defmodule APDS9960.MixProject do
  use Mix.Project

  def project do
    [
      app: :apds9960,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      format: ["format", "credo --strict"]
    ]
  end
end
