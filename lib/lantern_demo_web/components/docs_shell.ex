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
      |> assign(:search_items, search_items())

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
      <dialog id="docs-search" class="docs-search" phx-hook="DocsSearch" aria-label="Search docs">
        <input type="text" class="docs-search-input" placeholder="Search components, guides, blocks…" autocomplete="off" spellcheck="false" aria-label="Search docs" />
        <ul class="docs-search-list" role="listbox">
          <li :for={i <- @search_items} data-text={i.text} role="option">
            <a href={i.href} data-phx-link="redirect" data-phx-link-state="push">
              <span>{i.title}</span><small>{i.crumb}</small>
            </a>
          </li>
        </ul>
        <div class="docs-search-empty" hidden>No results.</div>
      </dialog>
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

  # One search entry per page, plus one per member of a merged page so
  # "alert dialog" finds its section of the "Modal & alert dialog" page.
  defp search_items do
    for {s, p} <- Nav.all_pages(),
        item <- entries(s, p) do
      item
    end
  end

  defp entries(s, p) do
    base = Nav.path(p, s)

    page = %{
      title: p.title,
      crumb: s.title,
      href: base,
      text: down("#{p.title} #{s.title} #{p.desc}")
    }

    members =
      case p do
        %{members: [_, _ | _] = ms} ->
          for m <- ms do
            t = LanternDemoWeb.Docs.Nav.member_title(m)

            %{
              title: t,
              crumb: "#{s.title} › #{p.title}",
              href: "#{base}##{m}",
              text: down("#{t} #{p.title} #{s.title}")
            }
          end

        _ ->
          []
      end

    [page | members]
  end

  defp down(s), do: String.downcase(s)
end
