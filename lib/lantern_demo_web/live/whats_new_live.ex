defmodule LanternDemoWeb.WhatsNewLive do
  @moduledoc """
  Review showcase landing: every change in this branch, each with a link to
  the live page where the owner can see it.
  """
  use Phoenix.LiveView

  alias LanternUI.Components.Button

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "What's new — lantern-ui")}
  end

  def render(assigns) do
    ~H"""
    <LanternDemoWeb.DocsShell.shell current="whats-new">
      <article class="docs-body docs-body-wide">
        <h1>What's new</h1>
        <p>
          lantern-ui, live and clickable — every change in this review branch, each
          linked to the page that shows it. Flip the <strong>Default / shadcn</strong>
          switch and <strong>Dark</strong> toggle in the top bar: they work on every
          page below.
        </p>

        <section class="docs-section">
          <h2 class="docs-section-title">Page blocks — 8 live pages</h2>
          <p class="docs-section-desc">
            Whole pages copied from the lantern-ui block recipes, with real
            interactivity: the list filters and searches through the URL, dashboard
            chips filter activity, the detail panel toggles, and the form validates.
          </p>
          <div class="docs-row">
            <Button.button size="sm" navigate="/blocks/app-shell">App shell</Button.button>
            <Button.button size="sm" navigate="/blocks/dashboard">Dashboard</Button.button>
            <Button.button size="sm" navigate="/blocks/list">List</Button.button>
            <Button.button size="sm" navigate="/blocks/detail">Detail + inspector</Button.button>
            <Button.button size="sm" navigate="/blocks/settings">Settings</Button.button>
            <Button.button size="sm" navigate="/blocks/form">Form</Button.button>
            <Button.button size="sm" navigate="/blocks/login">Login</Button.button>
            <Button.button size="sm" navigate="/blocks/destructive">Destructive flow</Button.button>
          </div>
        </section>

        <section class="docs-section">
          <h2 class="docs-section-title">Toast deck</h2>
          <p class="docs-section-desc">
            Burst of 6 into a collapsed stack, Undo action, sticky until dismissed,
            put_flash bridging, a placement picker, and the toast-then-re-render
            regression check.
          </p>
          <div class="docs-row">
            <Button.button size="sm" navigate="/components/toast">Toast page</Button.button>
          </div>
        </section>

        <section class="docs-section">
          <h2 class="docs-section-title">Theme switch: Default | shadcn, Light | Dark</h2>
          <p class="docs-section-desc">
            The top-bar switch drives <code>&lt;Theme.theme preset=&quot;shadcn&quot;&gt;</code>
            on every page; the theming page keeps the full token editor.
          </p>
          <div class="docs-row">
            <Button.button size="sm" navigate="/components/theming">Theming page</Button.button>
          </div>
        </section>

        <section class="docs-section">
          <h2 class="docs-section-title">Select: client + server-driven</h2>
          <p class="docs-section-desc">
            The default client mode (Zag owns the value, no round trip) next to a
            controlled mode where the server value is truth — pick in the listbox or
            drive it from the server buttons.
          </p>
          <div class="docs-row">
            <Button.button size="sm" navigate="/components/select">Select page</Button.button>
          </div>
        </section>

        <section class="docs-section">
          <h2 class="docs-section-title">Widgets on Zag</h2>
          <p class="docs-section-desc">
            Tooltip, popover, switch, radio, the dialog family, menu/dropdown,
            accordion, slider, tabs, and pagination now run on Zag state machines
            (client mode by default, server-driven where it matters) — same
            lantern markup and tokens, real keyboard and ARIA behavior.
          </p>
          <div class="docs-row">
            <Button.button size="sm" navigate="/components/tooltip">Tooltip</Button.button>
            <Button.button size="sm" navigate="/components/popover">Popover</Button.button>
            <Button.button size="sm" navigate="/components/switch">Switch</Button.button>
            <Button.button size="sm" navigate="/components/radio">Radio</Button.button>
            <Button.button size="sm" navigate="/components/modal">Modal</Button.button>
            <Button.button size="sm" navigate="/components/alert-dialog">Alert dialog</Button.button>
            <Button.button size="sm" navigate="/components/sheet">Sheet</Button.button>
            <Button.button size="sm" navigate="/components/menu">Menu and menubar</Button.button>
            <Button.button size="sm" navigate="/components/dropdown">Dropdown menu</Button.button>
            <Button.button size="sm" navigate="/components/accordion">Accordion</Button.button>
            <Button.button size="sm" navigate="/components/slider">Slider</Button.button>
            <Button.button size="sm" navigate="/components/tabs">Tabs</Button.button>
            <Button.button size="sm" navigate="/components/pagination">Pagination</Button.button>
          </div>
        </section>

        <section class="docs-section">
          <h2 class="docs-section-title">Flat lists — group bands are gone</h2>
          <p class="docs-section-desc">
            No collapsible group headers anywhere: one flat list, a status glyph on
            every row, filter chips with counts above.
          </p>
          <div class="docs-row">
            <Button.button size="sm" navigate="/components/list-row">List row page</Button.button>
            <Button.button size="sm" variant="outline" navigate="/blocks/list">
              List block
            </Button.button>
          </div>
        </section>
      </article>
    </LanternDemoWeb.DocsShell.shell>
    """
  end
end
