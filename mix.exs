defmodule Base1.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nocursor/base1"

  def project do
    [
      app: :base1,
      version: @version,
      elixir: ">= 1.7.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Elixir library for encoding and decoding binaries in Base1 - Binary encoding inspired by unary numbers.",
      package: package(),

      # Docs
      name: "Base1",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
    ]
  end

  defp package do
    [
      maintainers: [
        "nocursor",
      ],
      licenses: ["MIT"],
      links: %{github: @source_url},
      files: ~w(lib NEWS.md LICENSE.md mix.exs README.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extra_section: "PAGES",
      extras: extras(),
    ]
  end

  defp extras do
    [
      "README.md",
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.13.2", only: [:dev]},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.13", only: [:dev], runtime: false},
    ]
  end
end
