defmodule Individual.Mixfile do
  use Mix.Project

  def project do
    [
      app: :individual,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: []

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 2.1", only: [:dev, :test]}
    ]
  end
end
