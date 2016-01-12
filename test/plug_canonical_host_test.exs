defmodule PlugCanonicalHostTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TestApp do
    use Plug.Router

    plug PlugCanonicalHost, canonical_host: "example.com"
    plug :match
    plug :dispatch

    get "/foo" do
      conn |> send_resp(200, "Hello World")
    end
  end

  @opts TestApp.init([])

  defp get(uri) do
    conn(:get, uri)
    |> TestApp.call(TestApp.init([]))
  end

  test "redirects to canonical host" do
    conn = get(URI.parse("http://www.example.com/foo?bar=1"))

    assert conn.status == 301
    assert get_resp_header(conn, "location") === ["http://example.com/foo?bar=1"]
  end

  test "does not redirect to canonical host when already on canonical host" do
    conn = get(URI.parse("http://example.com/foo"))

    assert conn.status == 200
    assert conn.resp_body == "Hello World"
  end

end
