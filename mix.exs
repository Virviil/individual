defmodule Individual.Mixfile do
  use Mix.Project

  def project do
    [
      app: :individual,
      version: "0.1.1",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Individual",
      source_url: "https://github.com/virviil/individual"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: [
    mod: {Individual.Application, []},
  ]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 2.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.0", only: :dev},
    ]
  end

  defp description() do
    "Process adapter to handle singleton processes in Elixir applications."
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
