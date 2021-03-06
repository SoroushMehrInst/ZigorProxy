defmodule ZigorProxy.Mixfile do
  use Mix.Project

  def project do
    [app: :zigor_proxy,
     version: "0.2.3",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     #Docs
     name: "Zigor Proxy Server",
     source_url: "https://github.com/Resaneh24/ZigorProxy",
     homepage_url: "http://r24.ir/Projects/ZigorProxy",
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ssl],
     mod: {ZigorProxy, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.14.4", only: :dev},
      {:distillery, "~> 1.4"}
    ]
  end
end
