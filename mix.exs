defmodule Individual.Mixfile do
  use Mix.Project

  @source_url "https://github.com/virviil/individual"
  @version "0.3.2"

  def project do
    [
      app: :individual,
      version: @version,
      elixir: "~> 1.5",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      name: "Individual",
      docs: docs()
    ]
  end

  def application, do: []

  defp deps do
    [
      {:libcluster, "~> 2.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.0", only: :dev}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp package() do
    [
      description: "Process adapter to handle singleton processes in Elixir applications.",
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Dmitry Rubinstein"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
