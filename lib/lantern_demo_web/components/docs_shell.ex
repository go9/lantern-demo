defmodule LanternDemoWeb.DocsShell do
  @moduledoc """
  The shared docs shell, built on lantern_ui's own `app_shell` (dogfood): a
  collapsible sidebar of collapsible section groups (from `Docs.Nav`), a
  breadcrumb header, theme/density/preset toggles, and a Cmd+K docs search.

  `current` is `"docs"`, a section id, or `"section/page"` (see `Docs.Nav`).
  """
  use Phoenix.Component

  alias LanternDemoWeb.Docs.Nav
  alias LanternUI.Components.Breadcrumb
  alias LanternUI.Components.Button
  alias LanternUI.Components.Icon
  alias LanternUI.Components.Layout
  alias LanternUI.Components.Theme

  @suggest ~w(/docs/getting-started/installation /docs/forms/buttons /docs/data-display/tables-lists /docs/data-display/data-table /docs/feedback/toasts /docs/overlays/dialogs /docs/overlays/command /docs/foundations/status /docs/getting-started/theming /blocks/list)

  attr(:current, :string, required: true)
  attr(:theme, :string, default: "system")
  attr(:density, :string, default: "compact")
  slot(:actions)
  slot(:inner_block, required: true)

  def shell(assigns) do
    {section, page} = locate(assigns.current)

    assigns =
      assigns
      |> assign(:sections, Nav.sections())
      |> assign(:section, section)
      |> assign(:page, page)
      |> assign(:suggest, @suggest)

    ~H"""
    <Layout.app_shell
      id="lantern-demo-shell"
      class={[@theme == "dark" && "dark", @theme == "light" && "light"]}
      data-lantern-density={@density}
    >
      <:brand>
        <Icon.icon name="squares-2x2" /> <span class="lui-brand-name">lantern</span>
      </:brand>
      <:header>
        <Breadcrumb.breadcrumb aria_label="Location">
          <:item href="/docs">Docs</:item>
          <:item :if={@section && @page} href={Nav.path(@section)}>{@section.title}</:item>
          <:item current>{(@page && @page.title) || (@section && @section.title) || "Overview"}</:item>
        </Breadcrumb.breadcrumb>
      </:header>
      <:actions>
        <div id="demo-chrome" phx-hook="DemoChrome" data-shell="lantern-demo-shell" class="demo-chrome">
          <Button.button variant="outline" size="sm" type="button" data-docs-search-open class="docs-search-btn">
            <Icon.icon name="magnifying-glass" /> <span>Search docs</span> <kbd>⌘K</kbd>
          </Button.button>
          <Button.button variant="outline" size="sm" type="button" data-part="theme-toggle">
            <span data-part="theme-label">Dark</span>
          </Button.button>
          <Button.button variant="outline" size="sm" type="button" data-part="density-toggle">
            <span data-part="density-label">Compact</span>
          </Button.button>
          <Button.button
            variant="outline"
            size="sm"
            type="button"
            data-part="preset-toggle"
            title="Toggle the shadcn preset (<Theme.theme preset>)"
          >
            <span data-part="preset-label">Default</span>
          </Button.button>
        </div>
        {render_slot(@actions)}
      </:actions>

      <:sidebar>
        <%!-- One nav_group for everything: a nav_group per section stacked a 16px group
            margin between every section header (46px pitch instead of ~34px). --%>
        <Layout.nav_group>
          <Layout.nav_item label="Overview" icon="squares-2x2" navigate="/docs" active={@current == "docs"} />
          <Layout.nav_item
            :for={s <- @sections}
            label={s.title}
            icon={s.icon}
            expanded={@section != nil && @section.id == s.id}
            active={false}
          >
            <:subnav>
              <Layout.nav_item label="Overview" navigate={Nav.path(s)} active={@current == s.id} />
              <Layout.nav_item
                :for={p <- s.pages}
                label={p.title}
                navigate={Nav.path(p, s)}
                active={@current == "#{s.id}/#{p.id}"}
              />
            </:subnav>
          </Layout.nav_item>
        </Layout.nav_group>
      </:sidebar>

      <Theme.theme />
      <%!-- Not a <dialog>: a plain overlay behaves the same in every browser and survives
          LiveView patches (phx-update="ignore" — the hook owns this subtree). --%>
      <div
        id="docs-search"
        class="docs-search"
        phx-hook="DocsSearch"
        phx-update="ignore"
        data-index="/docs/search.json"
        data-suggest={Jason.encode!(@suggest)}
        hidden
      >
        <div class="docs-search-backdrop" data-close></div>
        <div class="docs-search-panel" role="dialog" aria-modal="true" aria-label="Search docs">
          <input
            type="text"
            class="docs-search-input"
            placeholder="Search components, props, guides, blocks…"
            autocomplete="off"
            autocapitalize="off"
            spellcheck="false"
            role="combobox"
            aria-expanded="true"
            aria-controls="docs-search-list"
            aria-label="Search docs"
          />
          <div id="docs-search-list" class="docs-search-list" role="listbox"></div>
          <div class="docs-search-foot"><span>↑↓ navigate</span><span>↵ open</span><span>esc close</span></div>
        </div>
      </div>
      {render_slot(@inner_block)}
    </Layout.app_shell>

    <style>
      .demo-chrome { display: inline-flex; gap: 0.4rem; flex-wrap: wrap; }
      .lui-nav-item-soon { opacity: 0.5; pointer-events: none; }
      .demo-chrome { flex-wrap: nowrap; }
      @media (max-width: 720px) {
        .docs-search-btn span, .docs-search-btn kbd { display: none; }
        .docs-search-btn { min-width: 0; }
        .demo-chrome [data-part="density-toggle"], .demo-chrome [data-part="preset-toggle"] { display: none; }
      }

      /* Embedded DB-viewer demo: drop the standalone marketing chrome so it reads
         as a tool page inside the shell. */
      .lui-app-main .demo-shell { background: none; padding: 0; min-height: 0; }
      .lui-app-main .demo-shell > * { max-width: 940px; margin-left: 0; margin-right: 0; }
      .lui-app-main .demo-hero { margin-bottom: 1rem; }
      .lui-app-main .demo-title { font-size: 1.5rem; }
      .lui-app-main .demo-eyebrow { display: none; }
    </style>
    """
  end

  defp locate("docs"), do: {nil, nil}

  defp locate(current) do
    case String.split(current, "/", parts: 2) do
      [sid, pid] ->
        case Nav.page(sid, pid) do
          {s, p} -> {s, p}
          nil -> {nil, nil}
        end

      [sid] ->
        {Nav.section(sid), nil}
    end
  end
end
