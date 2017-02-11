defmodule PlugCanonicalHost do
  @moduledoc """
  A Plug for ensuring that all requests are served by a single canonical host
  """

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

  @doc """
  Initialize this plug with a canonical host option.
  """
  def init(opts), do: Keyword.fetch!(opts, :canonical_host)

  @doc """
  Call the plug.
  """
  def call(conn = %Plug.Conn{host: host}, canonical_host)
    when is_nil(canonical_host) == false and canonical_host !== "" and host !== canonical_host do
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
    "#{conn.scheme}://#{conn.host}:#{canonical_port(conn)}#{conn.request_path}?#{conn.query_string}"
  end

  defp canonical_port(conn = %Plug.Conn{port: port}) do
    case get_req_header(conn, "x-forwarded-port") do
      [forwarded_port] -> forwarded_port
      [] -> port
    end
  end
end
