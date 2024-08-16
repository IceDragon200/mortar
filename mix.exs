defmodule Mortar.MixProject do
  use Mix.Project

  def project do
    [
      app: :mortar,
      description: description(),
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Mortar is a library of various utilities that got copied around a little too much.
    """
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:csv, "~> 2.0 or ~> 3.0"},
      {:ecto, "~> 3.0"},
      {:ecto_ulid, "~> 0.3"},
    ]
  end

  defp package do
    [
      maintainers: ["Corey Powell"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/IceDragon200/mortar"
      },
    ]
  end
end
