defmodule XUtil.MixProject do
  use Mix.Project

  def project do
    [
      app: :x_util,
      version: "0.1.0",
      build_path: "_build",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.11",
      consolidate_protocols: Mix.env() != :test,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:comb, git: "https://github.com/tallakt/comb.git", tag: "master"},
      {:assertions, "~> 0.10", only: :test},
      {:credo, "~> 1.5.1", only: [:dev, :test], runtime: false}
    ]
  end
end
