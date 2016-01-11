defmodule PlugCanonicalHost do
  import Plug.Conn

  @location_header "location"
  @status_code 301
  @html_template """
    <!DOCTYPE html>
    <html lang="en-US">
      <head><title>301 Moved Permanently</title></head>
      <body>
        <h1>Moved Permanently</h1>
        <p>The document has moved <a href="%s">here</a>.</p>
      </body>
    </html>
  """

  def init(canonical_host), do: canonical_host

  def call(conn = %Plug.Conn{host: host}, canonical_host) when host !== canonical_host do
    location = conn |> redirect_location(canonical_host)

    conn
    |> put_resp_header(@location_header, location)
    |> send_resp(@status_code, String.replace(@html_template, "%s", location))
    |> halt
  end

  def call(conn, _), do: conn

  defp redirect_location(conn, canonical_host) do
    conn
    |> request_uri
    |> URI.parse
    |> Map.put(:host, canonical_host)
    |> URI.to_string
  end

  defp request_uri(conn) do
    "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}#{conn.query_string}"
  end
end
