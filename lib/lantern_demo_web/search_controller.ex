defmodule LanternDemoWeb.SearchController do
  @moduledoc "Serves the docs search index (see `LanternDemoWeb.Docs.Search`)."
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("cache-control", "public, max-age=300")
    |> send_resp(200, LanternDemoWeb.Docs.Search.json())
  end
end
