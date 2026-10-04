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
