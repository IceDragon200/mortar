defmodule Mortar.MixProject do
  use Mix.Project

  def project do
    [
      app: :mortar,
      version: "0.1.0",
      elixir: "~> 1.12",
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
      {:csv, "~> 2.0 or ~> 3.0"},
      {:ecto, "~> 3.0"},
      {:ecto_ulid, "~> 0.3"},
    ]
  end
end
