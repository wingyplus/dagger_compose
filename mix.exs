defmodule Dagger.Compose.MixProject do
  use Mix.Project

  def project do
    [
      app: :dagger_compose,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dagger, github: "dagger/dagger", sparse: "sdk/elixir"},
      {:yaml_elixir, "~> 2.9"}
    ]
  end
end
