defmodule LanternDemoWeb.WhatsNewLive do
  @moduledoc """
  The landing page for this release: a hero, then one card per change with a
  thumbnail, a one-line description and a link or two. The single call to
  action opens the demo app.
  """
  use Phoenix.LiveView

  alias LanternUI.Components.Button

  @cards [
    %{
      id: "blocks",
      title: "Page blocks",
      desc:
        "Eight copy-paste pages — dashboard, list, detail, settings, form, login — each live and interactive.",
      thumb: "/wn/blocks.jpg",
      links: [{"Browse the blocks", "/docs/blocks"}, {"Dashboard", "/blocks/dashboard"}]
    },
    %{
      id: "toast",
      title: "Toast deck",
      desc:
        "Stacked notifications with actions, sticky toasts, put_flash bridging and placement.",
      thumb: "/wn/toast.jpg",
      links: [{"Toasts", "/docs/feedback/toasts"}]
    },
    %{
      id: "shadcn",
      title: "shadcn preset",
      desc:
        "One attribute — <Theme.theme preset=\"shadcn\" /> — restyles every component, light and dark.",
      thumb: "/wn/shadcn.jpg",
      links: [
        {"Theming", "/docs/getting-started/theming"},
        {"Colors & tokens", "/docs/foundations/colors"}
      ]
    },
    %{
      id: "zag",
      title: "Zag widgets",
      desc:
        "Dialogs, menus, select, tooltip, tabs and more now run on Zag state machines with real keyboard and ARIA.",
      thumb: "/wn/zag.jpg",
      links: [
        {"Modal & alert dialog", "/docs/overlays/dialogs"},
        {"Select", "/docs/forms/select"}
      ]
    },
    %{
      id: "lists",
      title: "Flat lists",
      desc:
        "Group bands are gone: one flat list with a status glyph on every row and filter chips with counts.",
      thumb: "/wn/lists.jpg",
      links: [
        {"Tables & lists", "/docs/data-display/tables-lists"},
        {"List block", "/blocks/list"}
      ]
    },
    %{
      id: "ai",
      title: "AI legibility package",
      desc:
        "llms.txt, an AGENTS rules block, installable skills and a linter so coding agents build with lantern correctly.",
      thumb: "/wn/ai.jpg",
      links: [{"How it works", "/docs/getting-started/ai"}]
    }
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "What's new — lantern-ui", cards: @cards)}
  end

  def render(assigns) do
    ~H"""
    <LanternDemoWeb.DocsShell.shell current="getting-started/whats-new">
      <div class="wn">
        <header class="wn-hero">
          <p class="wn-eyebrow">What's new</p>
          <h1 class="wn-title">Pages, not parts.</h1>
          <p class="wn-sub">
            This release ships whole page blocks, a toast deck, a shadcn-style preset, Zag-powered widgets,
            flat lists and a package that makes lantern legible to coding agents.
          </p>
          <div class="wn-cta">
            <Button.button variant="solid" size="lg" navigate="/app">Open the demo app</Button.button>
            <span class="wn-cta-note">A fully working ticket tracker built only from lantern components.</span>
          </div>
        </header>

        <div class="wn-grid">
          <article :for={c <- @cards} id={"wn-#{c.id}"} class="wn-card">
            <div class="wn-thumb"><img src={c.thumb} alt={"#{c.title} screenshot"} loading="lazy" /></div>
            <div class="wn-card-body">
              <h2 class="wn-card-title">{c.title}</h2>
              <p class="wn-card-desc">{c.desc}</p>
              <div class="wn-links">
                <.link :for={{label, href} <- c.links} navigate={href}>{label} →</.link>
              </div>
            </div>
          </article>
        </div>
      </div>
    </LanternDemoWeb.DocsShell.shell>
    """
  end
end
