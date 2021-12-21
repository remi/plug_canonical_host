<p align="center">
  <img src="https://user-images.githubusercontent.com/11348/56806359-b6a07f00-67f9-11e9-96bd-6a456a96880c.png" width="600" />
  <br /><br />
  <code>PlugCanonicalHost</code> ensures that all requests are served by a single canonical host.<br /> It will redirect all requests from non-canonical hosts to the canonical one.
  <br /><br />
  <a href="https://github.com/remi/plug_canonical_host/actions?query=workflow%3ACI+branch%3Amaster+event%3Apush"><img src="https://github.com/remi/plug_canonical_host/workflows/CI/badge.svg?branch=master&event=push" /></a>
  <a href="https://hex.pm/packages/plug_canonical_host"><img src="https://img.shields.io/hexpm/v/plug_canonical_host.svg" /></a>
</p>

## Installation

Add `plug_canonical_host` to the `deps` function in your project’s `mix.exs` file:

```elixir
defp deps do
  [
    …,
    {:plug_canonical_host, "~> 2.0"}
  ]
end
```

Then run `mix do deps.get, deps.compile` inside your project’s directory.

## Usage

`PlugCanonicalHost` can be used just as any other plugs. Add `PlugCanonicalHost` before all of the other plugs you want to happen after successful redirect to your canonical host.

The recommended way to define a canonical host is with an environment variable.

```elixir
# config/releases.exs
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

For example, if your `CANONICAL_HOST` is `www.example.com` but your application is accessible via both `example.com` and `www.example.com`, all traffic coming through `example.com` will be redirected (with a `301` HTTP status) to the matching `www.example.com` URL.

```bash
$ curl -sI "http://example.com/foo?bar=1"
#> HTTP/1.1 301 Moved Permanently
#> Location: http://www.example.com/foo?bar=1
```

### Allow multiple hosts

If you want to support _multiple_ hosts, you can make them skip the canonical host behavior but you’re still going to have to specify a canonical host for unsupported hosts redirects.

```elixir
# config/releases.exs
config :my_app,
  canonical_host: System.get_env("CANONICAL_HOST"),
  supported_hosts: String.split(System.get_env("SUPPORTED_HOSTS"), ",")

# lib/my_app/endpoint.ex
defmodule MyApp.Endpoint do
  plug(:canonical_host)

  defp canonical_host(%Plug.Conn{host: host} = conn, _opts) do
    canonical_host = Application.get_env(:app, :canonical_host)
    supported_hosts = Application.get_env(:my_app, :supported_hosts)

    cond do
      host in supported_hosts ->
        conn
      is_binary(canonical_host) ->
        opts = PlugCanonicalHost.init(canonical_host: canonical_host)
        PlugCanonicalHost.call(conn, opts)
      true ->
        conn
    end
  end
end
```

Let’s say we have `CANONICAL_HOST=www.example.com` and `SUPPORTED_HOSTS=foo.example.com,bar.example.com`.

Now, all requests going through `www.example.com`, `foo.example.com` or `bar.example.com` path will skip the canonical host redirect behavior. Other hosts will redirect to `www.example.com`.

```bash
$ curl -sI "http://example.com/foo?bar=1"
#> HTTP/1.1 301 Moved Permanently
#> Location: http://www.example.com/foo?bar=1

$ curl -sI "http://foo.example.com/foo?bar=1"
#> HTTP/1.1 200 OK

$ curl -sI "http://bar.example.com/foo?bar=1"
#> HTTP/1.1 200 OK

$ curl -sI "http://www.example.com/foo?bar=1"
#> HTTP/1.1 200 OK
```

### Exclude certain requests

If you want to _exclude_ certain requests from redirecting to the canonical host, you can use simple pattern matching in your function arguments:

```elixir
# config/releases.exs
config :my_app,
  canonical_host: System.get_env("CANONICAL_HOST")

# lib/my_app/endpoint.ex
defmodule MyApp.Endpoint do
  plug(:canonical_host)

  defp canonical_host(%Plug.Conn{request_path: "/ignore-me"} = conn, _opts) do
    Plug.Conn.send_resp(conn, 200, "👋")
  end

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

Now, all requests going to the `/ignore-me` path will skip the canonical host redirect behavior.

```bash
$ curl -sI "http://example.com/foo?bar=1"
#> HTTP/1.1 301 Moved Permanently
#> Location: http://www.example.com/foo?bar=1

$ curl -sI "http://example.com/ignore-me"
#> HTTP/1.1 200 OK
```

## License

`PlugCanonicalHost` is © 2016-2020 [Rémi Prévost](http://exomel.com) and may be freely distributed under the [MIT license](https://github.com/remi/plug_canonical_host/blob/master/LICENSE.md). See the `LICENSE.md` file for more information.

The plug logo is based on [this lovely icon by Vectors Market](https://thenounproject.com/term/usb-plug/298582), from The Noun Project. Used under a [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/) license.
