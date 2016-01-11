defmodule PlugCanonicalHost.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_canonical_host,
     version: "0.2.0",
     elixir: "~> 1.0",
     deps: deps,
     package: package,
     name: "Plug Canonical Host",
     source_url: "https://github.com/remiprev/plug_canonical_host",
     homepage_url: "https://github.com/remiprev/plug_canonical_host",
     description: "A Plug for ensuring that all requests are made to a single canonical host",
     docs: [readme: "README.md", main: "README"]]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:plug, " ~> 1.0"}]
  end

  defp package do
    %{
      maintainers: ["Rémi Prévost"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/remiprev/plug_canonical_host"
      }
    }
  end
end
