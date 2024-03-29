defmodule Elixter.Mixfile do
  use Mix.Project

  def project do
    [app: :elixter,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: [main_module: Elixter],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:httpoison, "~> 0.12"},
     {:floki, "~> 0.17.0"},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false}]
  end
end
