defmodule Seqy.MixProject do
  use Mix.Project

  @source_url "https://github.com/vinceurag/seqy"

  def project do
    [
      app: :seqy,
      version: "0.1.1",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: @source_url,
      docs: [
        main: "Seqy"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Seqy.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Vince Urag"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp description() do
    "Seqy is an events sequentializer. Need to process events in a specific order? Seqy can help."
  end
end
