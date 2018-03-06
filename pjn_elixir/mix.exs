defmodule Pjn.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pjn,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      # mod: {Ex1, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:expyplot, "~> 1.1.2"},
      {:flow, "~> 0.13"},
    ]
  end
end
