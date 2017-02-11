PlugCanonicalHost
=================

[![Travis](https://img.shields.io/travis/remiprev/plug_canonical_host.svg?style=flat-square)](https://travis-ci.org/remiprev/plug_canonical_host)
[![Hex.pm](https://img.shields.io/hexpm/v/plug_canonical_host.svg?style=flat-square)](https://hex.pm/packages/plug_canonical_host)

`PlugCanonicalHost` ensures that all requests are served by a single canonical
host. It will redirect all requests from non-canonical hosts to the canonical
one.

Installation
------------

Add `plug_canonical_host` to the `deps` function in your project's `mix.exs` file:

```elixir
defp deps do
  [
    …,
    {:plug_canonical_host, "~> 0.3"}
  ]
end
```

Then run `mix do deps.get, deps.compile` inside your project's directory.

Usage
-----

`PlugCanonicalHost` can be used just as any other plugs. Add `PlugCanonicalHost`
before all of the other plugs you want to happen after successful redirection
to your canonical host.

```elixir
defmodule Endpoint do
  plug PlugCanonicalHost, canonical_host: "www.example.com"
end
```

For example, If your application is accessible via both `example.com` and
`www.example.com`, all traffic coming through `example.com` will be redirected
(with a `301` HTTP status) to the matching `wwww.example.com` URL.

License
-------

`PlugCanonicalHost` is © 2016 [Rémi Prévost](http://exomel.com) and may be
freely distributed under the [MIT license](https://github.com/remiprev/plug_canonical_host/blob/master/LICENSE.md). See the
`LICENSE.md` file for more information.
