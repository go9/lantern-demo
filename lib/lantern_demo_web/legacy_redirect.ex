defmodule LanternDemoWeb.LegacyRedirect do
  @moduledoc "Keeps the old `/components/:slug` URLs working by redirecting to the new docs IA."
  import Plug.Conn

  alias LanternDemoWeb.Docs.Nav

  def init(opts), do: opts

  def call(%{path_params: %{"slug" => slug}} = conn, _opts) do
    redirect(conn, Nav.legacy_path(slug) || "/docs")
  end

  def call(conn, _opts), do: redirect(conn, "/docs")

  defp redirect(conn, to) do
    conn |> put_resp_header("location", to) |> send_resp(301, "") |> halt()
  end
end
