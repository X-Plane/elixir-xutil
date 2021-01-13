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
      elixirc_options: [warnings_as_errors: halt_on_warnings?(Mix.env())],
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
      {:assertions, "~> 0.10", only: :test}
    ]
  end

  # Clever hack to allow unused functions and the like in test, but not dev or prod:
  # https://blog.rentpathcode.com/elixir-warnings-as-errors-sometimes-f5a8d2c96b15
  defp halt_on_warnings?(:test), do: false
  defp halt_on_warnings?(_), do: true
end
