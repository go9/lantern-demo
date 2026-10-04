defmodule LanternDemoWeb.Docs.Guides do
  @moduledoc "Hand-written foundation + getting-started pages (no component members)."
  use LanternDemoWeb.Docs.Section

  alias LanternDemoWeb.Docs.Page
  alias LanternUI.Components.Layout

  @tokens [
    {"Surfaces", ~w(surface surface-raised surface-sunken surface-hover)},
    {"Text", ~w(fg fg-muted fg-subtle)},
    {"Borders", ~w(border border-strong)},
    {"Brand", ~w(primary primary-fg secondary secondary-fg accent accent-soft accent-fg)},
    {"Status", ~w(success warning danger info)}
  ]

  @type_roles [
    {"--lantern-text", "Body text", "text"},
    {"--lantern-text-sm", "Small body text", "text-sm"},
    {"--lantern-text-meta", "Meta — dates, counts, secondary labels", "text-meta"},
    {"--lantern-text-caption", "Caption — uppercase micro-labels", "text-caption"},
    {"--lantern-text-mono-meta", "Mono meta — ids and codes", "text-mono-meta"}
  ]

  def page(%{page_id: "installation"} = assigns) do
    ~H"""
    <Page.frame section={@section} page={@page}>
      <div class="docs-prose">
        <h2>1. Add the dependency</h2>
        <p>lantern_ui ships from Hex. Add it to <code>mix.exs</code> and run <code>mix deps.get</code>.</p>
        <.snippet id="inst-deps" code={~S'{:lantern_ui, "~> 0.8"}'} />
        <h2>2. Load the assets</h2>
        <p>
          Serve <code>lantern_ui.css</code>, <code>lantern_ui_theme.css</code> and the hooks bundle (plus its
          <code>zag/</code> and <code>chunks/</code> directories — Zag widgets import them lazily) from <code>priv/static</code>.
        </p>
        <.snippet id="inst-assets" code={~S'''
        plug Plug.Static, at: "/", from: {:lantern_ui, "priv/static"},
          only: ~w(lantern_ui.css lantern_ui_theme.css lantern_ui_hooks.js zag chunks)

        # root layout
        <link rel="stylesheet" href="/lantern_ui_theme.css" />
        <link rel="stylesheet" href="/lantern_ui.css" />

        // app.js
        import LanternUIHooks from "/lantern_ui_hooks.js"
        new LiveSocket("/live", Socket, { hooks: { ...LanternUIHooks } })
        '''} />
        <h2>3. Import components and mount the theme</h2>
        <p>Import what you use, and mount <code>&lt;.theme /&gt;</code> once in the layout to enable dark mode and presets.</p>
        <.snippet id="inst-use" code={~S'''
        use LanternUI                      # imports every component
        # or: import LanternUI.Components.Button

        <LanternUI.Components.Theme.theme preset="shadcn" />
        '''} />
      </div>
    </Page.frame>
    """
  end

  def page(%{page_id: "ai"} = assigns) do
    ~H"""
    <Page.frame section={@section} page={@page}>
      <div class="docs-prose">
        <p>
          lantern-ui ships everything a coding agent needs to build with it correctly — a model-readable
          reference, a rules block for your <code>AGENTS.md</code>, installable skills, and a linter that
          fails on the mistakes agents make most.
        </p>
        <h2>llms.txt</h2>
        <p>
          <code>llms.txt</code> is a one-screen rule list plus a one-line-per-component catalog;
          <code>llms-full.txt</code> adds every attribute table. Regenerated from the component registry, so it
          cannot drift.
        </p>
        <.snippet code={"mix lantern.llms           # regenerate (inside the lantern_ui package)\nmix lantern.llms --check   # fail CI when stale"} />
        <h2>Rules agents follow</h2>
        <ul>
          <li>Build with lantern components in HEEx — never reach for React or a JS component library.</li>
          <li>One flat list: a status column on each row, filter chips with counts. No group headers.</li>
          <li>Never hand-roll a table or button where <code>table/1</code>, <code>data_table/1</code> or <code>button/1</code> exist.</li>
          <li>Semantic tokens only — no palette classes, no arbitrary pixel values.</li>
          <li>Title and actions live in the breadcrumb bar; no tabs as a default grouping mechanism.</li>
          <li>Copy the recipe HEEx; never hand-roll rows, glyphs, rings or rails.</li>
        </ul>
        <h2>Install into your app</h2>
        <p>Copies the skills and writes the rules block (with a fresh component catalog) into <code>AGENTS.md</code>.</p>
        <.snippet code={"mix lantern_ui.install_skills\nmix lantern_ui.install_skills ../my-app --force"} />
        <h2>Lint</h2>
        <p>Fails on bypassed tokens, banned grouped-list markup, hand-rolled tables/buttons and unknown component or attribute names — with did-you-mean hints.</p>
        <.snippet code={"mix lantern.lint\nmix lantern.lint --format json"} />
        <h2>Skills</h2>
        <p>
          Four skills ship with the package: <code>lantern-ui-components</code>, <code>lantern-recipes</code>,
          <code>lantern-migration</code> and <code>phoenix-page-design</code>.
        </p>
      </div>
    </Page.frame>
    """
  end

  def page(%{page_id: "colors"} = assigns) do
    assigns = assign(assigns, :tokens, @tokens)

    ~H"""
    <Page.frame section={@section} page={@page}>
      <div class="docs-prose">
        <p>
          Every color in lantern is a semantic CSS variable. Use the token, never a raw value — dark mode, the
          shadcn preset and your own themes all work by redefining these. Swatches below are live: toggle dark
          mode or the preset in the top bar.
        </p>
      </div>
      <section :for={{group, names} <- @tokens} class="docs-member">
        <h2 class="docs-member-title">{group}</h2>
        <div class="docs-swatches">
          <div :for={n <- names} class="docs-swatch">
            <div class="docs-swatch-chip" style={"background: var(--lantern-#{n})"}></div>
            <div class="docs-swatch-meta"><code>--lantern-{n}</code></div>
          </div>
        </div>
      </section>
    </Page.frame>
    """
  end

  def page(%{page_id: "typography"} = assigns) do
    assigns = assign(assigns, :roles, @type_roles)

    ~H"""
    <Page.frame section={@section} page={@page}>
      <div class="docs-prose"><p>Three families and a small set of text roles. Set the families once in your root layout.</p></div>
      <section class="docs-member">
        <h2 class="docs-member-title">Families</h2>
        <div class="docs-type-row"><code>--lantern-font</code><span style="font: var(--lantern-font); font-size: 1.1rem">The quick brown fox jumps over the lazy dog</span></div>
        <div class="docs-type-row"><code>--lantern-font-brand</code><span style="font-family: var(--lantern-font-brand); font-size: 1.1rem; font-weight: 700">The quick brown fox jumps over the lazy dog</span></div>
        <div class="docs-type-row"><code>--lantern-font-mono</code><span style="font-family: var(--lantern-font-mono); font-size: 1rem">The quick brown fox jumps over the lazy dog</span></div>
      </section>
      <section class="docs-member">
        <h2 class="docs-member-title">Text roles</h2>
        <div :for={{var, label, _} <- @roles} class="docs-type-row">
          <code>{var}</code><span style={"font-size: var(#{var})"}>{label}</span>
        </div>
      </section>
      <section class="docs-member">
        <h2 class="docs-member-title">Page header</h2>
        <p class="docs-section-desc">Titles come from <code>page_header</code>, never a hand-sized heading.</p>
        <div class="docs-demo"><Layout.page_header title="Tickets" description="Everything open across your projects." /></div>
      </section>
    </Page.frame>
    """
  end

  def page(%{page_id: "spacing"} = assigns) do
    ~H"""
    <Page.frame section={@section} page={@page}>
      <section class="docs-member">
        <h2 class="docs-member-title">Space tokens</h2>
        <div :for={n <- ~w(xs sm md lg)} class="docs-space-row">
          <code>--lantern-space-{n}</code>
          <span class="docs-space-bar" style={"width: var(--lantern-space-#{n})"}></span>
        </div>
      </section>
      <section class="docs-member">
        <h2 class="docs-member-title">Radii</h2>
        <div class="docs-row" style="display:flex;gap:1rem;flex-wrap:wrap">
          <div :for={n <- ~w(sm md lg)} class="docs-radius-box" style={"border-radius: var(--lantern-radius-#{n})"}>radius-{n}</div>
        </div>
      </section>
      <.demo_section
        title="Stack"
        description="stack/1 gives a run of children one gap (sm 0.5rem · md 0.75rem · lg 1.25rem) — pages never rely on margins collapsing."
        code={~S'''
        <.stack gap="lg">
          <.page_header title="Settings" />
          <.card title="Profile">…</.card>
          <.card title="Notifications">…</.card>
        </.stack>
        '''}
      >
        <Layout.stack gap="md">
          <LanternUI.Components.Card.card title="Profile" description="Name and avatar">Card one</LanternUI.Components.Card.card>
          <LanternUI.Components.Card.card title="Notifications" description="Email and push">Card two</LanternUI.Components.Card.card>
        </Layout.stack>
      </.demo_section>
      <.demo_section
        title="Density"
        description="Set data-lantern-density to compact or comfortable on any ancestor; controls, rows and tables follow. Use the Compact toggle in the top bar to try it."
        code={~S'<div data-lantern-density="compact">…</div>'}
      >
        <p class="docs-section-desc" style="margin:0">Control height <code>--lantern-control-h</code> and padding <code>--lantern-control-px</code> change with density.</p>
      </.demo_section>
    </Page.frame>
    """
  end
end
