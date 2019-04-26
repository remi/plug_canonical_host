<p align="center">
  <img src="https://user-images.githubusercontent.com/11348/56806359-b6a07f00-67f9-11e9-96bd-6a456a96880c.png" width="600" />
  <br /><br />
  <code>PlugCanonicalHost</code> ensures that all requests are served by a single canonical host.<br /> It will redirect all requests from non-canonical hosts to the canonical one.
  <br /><br />
  <a href="https://travis-ci.org/remiprev/plug_canonical_host"><img src="https://travis-ci.org/remiprev/plug_canonical_host.svg?branch=master" /></a>
  <a href="https://hex.pm/packages/plug_canonical_host"><img src="https://img.shields.io/hexpm/v/plug_canonical_host.svg" /></a>
</p>

Installation
------------

Add `plug_canonical_host` to the `deps` function in your project's `mix.exs` file:

```elixir
defp deps do
  [
    …,
    {:plug_canonical_host, "~> 1.0"}
  ]
end
```

Then run `mix do deps.get, deps.compile` inside your project's directory.

Usage
-----

`PlugCanonicalHost` can be used just as any other plugs. Add `PlugCanonicalHost` before all of the other plugs you want to happen after successful redirection to your canonical host.

The recommended way to define a canonical host is with an environment variable.

```elixir
# config/config.exs
config :my_app,
  canonical_host: System.get_env("CANONICAL_HOST")

# lib/my_app/endpoint.ex
defmodule MyApp.Endpoint do
  plug(:canonical_host)

  defp canonical_host(conn, _opts) do
    :my_app
    |> Application.get_env(:canonical_host)
    |> case do
      host when is_binary(host) ->
        opts = PlugCanonicalHost.init(canonical_host: host)
        PlugCanonicalHost.call(conn, opts)

      _ ->
        conn
    end
  end
end
```

For example, if your application is accessible via both `example.com` and `www.example.com`, all traffic coming through `example.com` will be redirected (with a `301` HTTP status) to the matching `www.example.com` URL.

```bash
$ curl -sI "http://example.com/foo?bar=1"
#> HTTP/1.1 301 Moved Permanently
#> Location: http://www.example.com/foo?bar=1
```

You can also specify requests to ignore (ie. that will pass through without redirecting to the canonical host).

```elixir
opts = PlugCanonicalHost.init(
  canonical_host: host,
  ignore: fn(%Conn{host: request_host}) ->
    # The argument is a `Plug.Conn` struct, which means we
    # can match on dozen of other fields (headers, query, etc.)
    #
    # Reference: https://hexdocs.pm/plug/Plug.Conn.html

    request_host in ["www.example.org"]
  end
)
```

Assuming `example.com`, `www.example.com` and `www.example.org` all point to our application:

```bash
$ curl -sI "http://example.com/foo?bar=1"
#> HTTP/1.1 301 Moved Permanently
#> Location: http://www.example.com/foo?bar=1

$ curl -sI "http://www.example.org/foo?bar=1"
#> HTTP/1.1 200 OK
```

License
-------

`PlugCanonicalHost` is © 2016-2019 [Rémi Prévost](http://exomel.com) and may be freely distributed under the [MIT license](https://github.com/remiprev/plug_canonical_host/blob/master/LICENSE.md). See the `LICENSE.md` file for more information.

The plug logo is based on [this lovely icon by Vectors Market](https://thenounproject.com/term/usb-plug/298582), from The Noun Project. Used under a [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/) license.
