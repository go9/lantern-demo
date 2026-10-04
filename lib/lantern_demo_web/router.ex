defmodule LanternDemoWeb.Router do
  use Phoenix.Router

  import Phoenix.Controller
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {LanternDemoWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  # The /app demo keeps per-visitor state keyed by a random id in the session cookie.
  def ensure_app_sid(conn, _opts) do
    case Plug.Conn.get_session(conn, "app_sid") do
      nil ->
        sid = Base.url_encode64(:crypto.strong_rand_bytes(12), padding: false)
        Plug.Conn.put_session(conn, "app_sid", sid)

      _ ->
        conn
    end
  end

  pipeline :app_session do
    plug(:ensure_app_sid)
  end

  scope "/app", LanternDemoWeb do
    pipe_through(:browser)
    pipe_through(:app_session)

    live("/", AppLive, :index)
    live("/*path", AppLive, :page)
  end

  scope "/", LanternDemoWeb do
    pipe_through(:browser)

    live("/", DemoLive, :index)
    live("/storage", S3DemoLive, :index)
    live("/livecode", LiveCodeDemoLive, :index)
    live("/whats-new", WhatsNewLive)
    live("/blocks/:name", BlocksLive)
    live("/preview/app-shell", AppShellPreviewLive)
    live("/docs/data-display/data-table", DataTableDemo)
    live("/docs/getting-started/theming", ThemingLive)
    live("/docs", DocsLive, :index)
    live("/docs/:section", DocsLive, :section)
    live("/docs/:section/:page", DocsLive, :page)
    get("/components", LegacyRedirect, [])
    get("/components/:slug", LegacyRedirect, [])
  end
end
