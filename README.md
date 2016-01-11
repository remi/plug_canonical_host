# PlugCanonicalHost

[What is that?]

## Installation

Add `plug_canonical_host` to the `deps` function in your project's `mix.exs` file:

```elixir
defp deps do
  [{:plug_basic_auth, "~> 0.1"}]
end
```

Then run `mix do deps.get, deps.compile` inside your project's directory.

## Usage

PlugBasicAuth can be used just as any other Plug. Add PlugBasicAuth before all of the other plugs you want to happen after successful redirection to your canonical host.

```elixir
defmodule Endpoint do
  plug PlugCanonicalHost, canonical_host: "www.example.com"
end
```

## License

PlugCanonicalHost is © 2016 [Rémi Prévost](http://exomel.com) and may be freely distributed under the [MIT license](https://github.com/remiprev/teamocil/blob/master/LICENSE.md). See the `LICENSE.md` file for more information.
