defmodule PlugCanonicalHost do
  @moduledoc """
  A Plug for ensuring that all requests are served by a single canonical host
  """

  # Imports
  import Plug.Conn

  # Aliases
  alias Plug.Conn

  # Behaviours
  @behaviour Plug

  # Constants
  @location_header "location"
  @forwarded_port_header "x-forwarded-port"
  @forwarded_proto_header "x-forwarded-proto"
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

  # Types
  @type opts :: binary | tuple | atom | integer | float | [opts] | %{opts => opts}

  @doc """
  Initialize this plug with a canonical host option.
  """
  @spec init(opts) :: opts
  def init(opts) do
    [
      canonical_host: Keyword.fetch!(opts, :canonical_host)
    ]
  end

  @doc """
  Call the plug.
  """
  @spec call(%Conn{}, opts) :: Conn.t()
  def call(conn = %Conn{host: host}, canonical_host: canonical_host)
      when is_nil(canonical_host) == false and canonical_host !== "" and host !== canonical_host do
    location = conn |> redirect_location(canonical_host)

    conn
    |> put_resp_header(@location_header, location)
    |> send_resp(@status_code, String.replace(@html_template, "%s", location))
    |> halt
  end

  def call(conn, _), do: conn

  @spec redirect_location(%Conn{}, String.t()) :: String.t()
  defp redirect_location(conn, canonical_host) do
    conn
    |> request_uri
    |> URI.parse()
    |> sanitize_empty_query()
    |> Map.put(:host, canonical_host)
    |> URI.to_string()
  end

  @spec request_uri(%Conn{}) :: String.t()
  defp request_uri(conn = %Conn{host: host, request_path: request_path, query_string: query_string}) do
    "#{canonical_scheme(conn)}://#{host}:#{canonical_port(conn)}#{request_path}?#{query_string}"
  end

  @spec canonical_port(%Conn{}) :: binary | integer
  defp canonical_port(conn = %Conn{port: port}) do
    case {get_req_header(conn, @forwarded_port_header), get_req_header(conn, @forwarded_proto_header)} do
      {[forwarded_port], _} -> forwarded_port
      {[], ["http"]} -> 80
      {[], ["https"]} -> 443
      {[], []} -> port
    end
  end

  @spec canonical_scheme(%Conn{}) :: binary
  defp canonical_scheme(conn = %Conn{scheme: scheme}) do
    case get_req_header(conn, @forwarded_proto_header) do
      [forwarded_proto] -> forwarded_proto
      [] -> scheme
    end
  end

  @spec sanitize_empty_query(%URI{}) :: %URI{}
  def sanitize_empty_query(uri = %URI{query: ""}), do: Map.put(uri, :query, nil)
  def sanitize_empty_query(uri), do: uri
end
