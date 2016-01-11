# PlugCanonicalHost

`PlugCanonicalHost` ensures that all your Elixir application requests are
coming through a single canonical host.

It will redirect all requests from non-canonical hosts to the canonical one.

## Installation

Add `plug_canonical_host` to the `deps` function in your project's `mix.exs`
file:

```elixir
defp deps do
  [
    …,
    {:plug_canonical_host, "~> 0.1"}
  ]
end
```

Then run `mix do deps.get, deps.compile` inside your project's directory.

## Usage

`PlugCanonicalHost` can be used just as any other plugs. Add `PlugCanonicalHost`
before all of the other plugs you want to happen after successful redirection
to your canonical host.

```elixir
defmodule Endpoint do
  plug PlugCanonicalHost, "www.example.com"
end
```

## License

`PlugCanonicalHost` is © 2016 [Rémi Prévost](http://exomel.com) and may be
freely distributed under the [MIT license](https://github.com/remiprev/plug_canonical_host/blob/master/LICENSE.md). See the
`LICENSE.md` file for more information.
