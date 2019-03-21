defmodule PlugCanonicalHostTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TestApp do
    use Plug.Router

    plug(PlugCanonicalHost, canonical_host: "example.com")
    plug(:match)
    plug(:dispatch)

    get "/foo" do
      conn |> send_resp(200, "Hello World")
    end
  end

  test "redirects to canonical host" do
    conn =
      :get
      |> conn("http://www.example.com/")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 301
    assert get_resp_header(conn, "location") === ["http://example.com/"]
  end

  test "redirects to canonical host with query string" do
    conn =
      :get
      |> conn("http://www.example.com/foo?bar=1")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 301
    assert get_resp_header(conn, "location") === ["http://example.com/foo?bar=1"]
  end

  test "redirects to forwarded port" do
    conn =
      :get
      |> conn("https://www.example.com/foo?bar=1")
      |> Map.put(:port, 80)
      |> put_req_header("x-forwarded-port", "443")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 301
    assert get_resp_header(conn, "location") === ["https://example.com/foo?bar=1"]
  end

  test "redirects to forwarded proto" do
    conn =
      :get
      |> conn("http://www.example.com/foo?bar=1")
      |> put_req_header("x-forwarded-proto", "https")
      |> put_req_header("x-forwarded-port", "443")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 301
    assert get_resp_header(conn, "location") === ["https://example.com/foo?bar=1"]
  end

  test "does not redirect to canonical host when already on canonical host" do
    conn =
      :get
      |> conn("http://example.com/foo")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 200
    assert conn.resp_body == "Hello World"
  end

  test "does not redirect when canonical host is an empty string" do
    conn =
      %Plug.Conn{host: "www.example.com", status: 200}
      |> PlugCanonicalHost.call("")

    assert conn.status == 200
  end

  test "does not redirect when canonical host is nil" do
    conn =
      %Plug.Conn{host: "www.example.com", status: 200}
      |> PlugCanonicalHost.call(nil)

    assert conn.status == 200
  end
end
