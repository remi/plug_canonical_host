defmodule PlugCanonicalHost.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project do
    [app: :plug_canonical_host,
     version: @version,
     elixir: "~> 1.1",
     deps: deps(),
     package: package(),
     name: "Plug Canonical Host",
     source_url: "https://github.com/remiprev/plug_canonical_host",
     homepage_url: "https://github.com/remiprev/plug_canonical_host",
     description: "A Plug for ensuring that all requests are served by a single canonical host",
     docs: [extras: ["README.md"], main: "readme", source_ref: "v#{@version}", source_url: "https://github.com/remiprev/plug_canonical_host"]]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:plug, " ~> 1.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
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
