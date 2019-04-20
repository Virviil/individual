defmodule Individual.Mixfile do
  use Mix.Project

  def project do
    [
      app: :individual,
      version: "0.3.1",
      elixir: "~> 1.5",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Individual",
      docs: docs(),
      source_url: "https://github.com/virviil/individual"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: []

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 2.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.0", only: :dev}
    ]
  end

  defp description() do
    "Process adapter to handle singleton processes in Elixir applications."
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md"
      ]
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Dmitry Rubinstein"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/virviil/individual"}
    ]
  end
end
