defmodule LanternDemoWeb.Docs.Structure do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "app-shell"} = assigns) do
    ~H"""
    <p>
      The chrome around this page — the top bar (brand · breadcrumb · actions), the
      fixed collapsible sidebar, and the main column — <strong>is</strong>
      <code>&lt;.app_shell&gt;</code>, built from lantern-ui components. Slots:
      <code>:brand</code> (corner logo), <code>:header</code> (inline
      breadcrumbs/switchers), <code>:actions</code> (top-right), and
      <code>:sidebar</code> (<code>nav_group</code> / <code>nav_item</code>). The
      collapse control at the sidebar foot persists per <code>id</code>.
    </p>
    <div class="docs-demo">
      <div class="docs-appshell-frame">
        <div class="docs-appshell-frame-bar" aria-hidden="true">
          <span></span><span></span><span></span>
        </div>
        <iframe
          src="/preview/app-shell"
          title="Live app_shell preview"
          loading="lazy"
          class="docs-appshell-iframe"
        >
        </iframe>
      </div>
      <p class="docs-caption">
        A real, interactive <code>&lt;.app_shell&gt;</code> — brand · breadcrumb ·
        actions over a collapsible sidebar and a main column. Rendered in an iframe
        because <code>app_shell</code> is <code>position: fixed</code>; the collapse
        control at the sidebar foot works here too.
      </p>
    </div>
    <.code_block id="code-app-shell" code={@snippets["app-shell"]} />
    <.demo_section
      title="Action bar"
      description="breadcrumb_bar with a trail plus :actions: trail left, actions right, one bar instead of a stacked breadcrumb and title row."
      code={~S'''
      <.breadcrumb_bar>
        <.breadcrumb>
          <:item href="#">Workspace</:item>
          <:item href="#">Projects</:item>
          <:item current>enventory</:item>
        </.breadcrumb>
        <:actions label="Share">
          <.button size="sm" variant="outline">Share</.button>
        </:actions>
        <:actions label="New deploy">
          <.button size="sm">New deploy</.button>
        </:actions>
      </.breadcrumb_bar>
      '''}
    >
      <Layout.breadcrumb_bar id="demo-bc-action-bar">
        <Breadcrumb.breadcrumb>
          <:item href="#">Workspace</:item>
          <:item href="#">Projects</:item>
          <:item current>enventory</:item>
        </Breadcrumb.breadcrumb>
        <:actions label="Share">
          <Button.button size="sm" variant="outline">Share</Button.button>
        </:actions>
        <:actions label="New deploy">
          <Button.button size="sm">New deploy</Button.button>
        </:actions>
      </Layout.breadcrumb_bar>
    </.demo_section>
    <.demo_section
      title="Page header"
      description="A title, supporting description, and right-side actions compose the page header below the breadcrumb."
      code={~S'''
      <.page_header title="Projects" description="Manage deployed resources">
        <:actions><.button>New project</.button></:actions>
      </.page_header>
      '''}
    >
      <Layout.page_header title="Projects" description="Manage deployed resources">
        <:actions><Button.button>New project</Button.button></:actions>
      </Layout.page_header>
    </.demo_section>
    <.demo_section
      title="Overflow"
      description="Only the first :max_inline entries (default 2) are quick buttons; the rest fold into the More menu. The same fold applies to the quick buttons themselves as the bar narrows, so nothing becomes unreachable on small screens."
      code={~S'''
      <.breadcrumb_bar>
        <.breadcrumb>
          <:item href="#">Workspace</:item>
          <:item current>foodfeed</:item>
        </.breadcrumb>
        <:actions label="Deploy">
          <.button size="sm">Deploy</.button>
        </:actions>
        <:actions label="Logs" phx-click="logs">
          <.button size="sm" variant="outline" phx-click="logs">Logs</.button>
        </:actions>
        <:actions label="Scale" phx-click="scale">
          <.button size="sm" variant="outline" phx-click="scale">Scale</.button>
        </:actions>
        <:actions label="Rollback" phx-click="rollback">
          <.button size="sm" variant="outline" phx-click="rollback">Rollback</.button>
        </:actions>
        <:actions label="Settings" phx-click="settings">
          <.button size="sm" variant="outline" phx-click="settings">Settings</.button>
        </:actions>
      </.breadcrumb_bar>
      '''}
    >
      <Layout.breadcrumb_bar id="demo-bc-overflow">
        <Breadcrumb.breadcrumb>
          <:item href="#">Workspace</:item>
          <:item current>foodfeed</:item>
        </Breadcrumb.breadcrumb>
        <:actions label="Deploy">
          <Button.button size="sm">Deploy</Button.button>
        </:actions>
        <:actions label="Logs" phx-click="logs">
          <Button.button size="sm" variant="outline" phx-click="logs">Logs</Button.button>
        </:actions>
        <:actions label="Scale" phx-click="scale">
          <Button.button size="sm" variant="outline" phx-click="scale">Scale</Button.button>
        </:actions>
        <:actions label="Rollback" phx-click="rollback">
          <Button.button size="sm" variant="outline" phx-click="rollback">Rollback</Button.button>
        </:actions>
        <:actions label="Settings" phx-click="settings">
          <Button.button size="sm" variant="outline" phx-click="settings">Settings</Button.button>
        </:actions>
      </Layout.breadcrumb_bar>
    </.demo_section>
    <.demo_section
      title="Destructive entry"
      description="Put data-confirm on the :actions slot. A folded item renders from slot attrs and never its body, so a confirm placed only on an inner button is lost once the entry folds."
      code={~S'''
      <.breadcrumb_bar>
        <.breadcrumb>
          <:item href="#">Workspace</:item>
          <:item current>skusync</:item>
        </.breadcrumb>
        <:actions label="Edit">
          <.button size="sm" variant="outline">Edit</.button>
        </:actions>
        <:actions label="Clone">
          <.button size="sm" variant="outline">Clone</.button>
        </:actions>
        <:actions
          label="Delete"
          phx-click="delete"
          data-confirm="Delete this project? This cannot be undone."
        >
          <.button
            size="sm"
            variant="outline"
            color="danger"
            phx-click="delete"
            data-confirm="Delete this project? This cannot be undone."
          >
            Delete
          </.button>
        </:actions>
      </.breadcrumb_bar>
      '''}
    >
      <Layout.breadcrumb_bar id="demo-bc-destructive">
        <Breadcrumb.breadcrumb>
          <:item href="#">Workspace</:item>
          <:item current>skusync</:item>
        </Breadcrumb.breadcrumb>
        <:actions label="Edit">
          <Button.button size="sm" variant="outline">Edit</Button.button>
        </:actions>
        <:actions label="Clone">
          <Button.button size="sm" variant="outline">Clone</Button.button>
        </:actions>
        <:actions
          label="Delete"
          phx-click="delete"
          data-confirm="Delete this project? This cannot be undone."
        >
          <Button.button
            size="sm"
            variant="outline"
            color="danger"
            phx-click="delete"
            data-confirm="Delete this project? This cannot be undone."
          >
            Delete
          </Button.button>
        </:actions>
      </Layout.breadcrumb_bar>
    </.demo_section>
    """
  end

  def member(%{member: "side-panel"} = assigns) do
    ~H"""
    <p>
      Collapsible right-hand panel plus a toggle that remembers open/closed in
      <code>localStorage</code>. Pair <code>side_panel_toggle</code> with
      <code>side_panel</code>. Markup-only persist uses
      <code>data-lantern-persist</code> on a different key.
    </p>
    <.demo_section
      title="Toggle and panel"
      description="Handle toggle_panel and set_panel. The hook restores the last choice; empty storage defaults open at ≥1280px."
      code={~S'''
      <.side_panel_toggle
        id="tickets-panel-toggle"
        panel_id="tickets-panel"
        panel_key="tickets-demo"
        open={@panel_open}
        phx-click="toggle_panel"
        kbd="]"
      />
      <.side_panel id="tickets-panel" open={@panel_open} aria-label="Project panel">
        <.inspector aria-label="Ticket">
          <.inspector_section title="Properties">
            <.description_list layout="dense">
              <:item label="Status">in_progress</:item>
            </.description_list>
          </.inspector_section>
        </.inspector>
      </.side_panel>
      '''}
    >
      <div class="docs-row">
        <SidePanel.side_panel_toggle
          id="tickets-panel-toggle"
          panel_id="tickets-panel"
          panel_key="tickets-demo"
          open={@panel_open}
          phx-click="toggle_panel"
          kbd="]"
        />
      </div>
      <SidePanel.side_panel id="tickets-panel" open={@panel_open} aria-label="Project panel">
        <Inspector.inspector aria-label="Ticket">
          <Inspector.inspector_section title="Properties">
            <DescriptionList.description_list layout="dense">
              <:item label="Status">in_progress</:item>
            </DescriptionList.description_list>
          </Inspector.inspector_section>
        </Inspector.inspector>
      </SidePanel.side_panel>
    </.demo_section>
    <.demo_section
      title="Markup persist"
      description="data-lantern-persist stores open/closed without a LiveView hook. Do not share a key with side_panel_toggle."
      code={~S'''
      <details data-lantern-persist="demo:side-filters">
        <summary>Filters</summary>
        Status, priority, and assignee.
      </details>
      '''}
    >
      <details data-lantern-persist="demo:side-filters">
        <summary>Filters</summary>
        Status, priority, and assignee.
      </details>
    </.demo_section>
    """
  end

  def member(%{member: "inspector"} = assigns) do
    ~H"""
    <p>
      Sticky right-rail: <code>inspector</code> wraps
      <code>inspector_section</code> headings and a
      <code>description_list</code> with <code>layout="dense"</code>.
      Values may be text or any inline control.
    </p>
    <.demo_section
      title="Properties rail"
      description="Section headings stay uppercase; values can hold badges or other lantern controls."
      code={~S'''
      <.inspector aria-label="Ticket">
        <.inspector_section title="Properties">
          <.description_list layout="dense">
            <:item label="Repo">enventory_new</:item>
            <:item label="Status">in_progress</:item>
            <:item label="Tags">
              <.badge size="sm">ui</.badge>
            </:item>
          </.description_list>
        </.inspector_section>
      </.inspector>
      '''}
    >
      <Inspector.inspector aria-label="Ticket">
        <Inspector.inspector_section title="Properties">
          <DescriptionList.description_list layout="dense">
            <:item label="Repo">enventory_new</:item>
            <:item label="Status">in_progress</:item>
            <:item label="Tags">
              <Badge.badge size="sm">ui</Badge.badge>
            </:item>
          </DescriptionList.description_list>
        </Inspector.inspector_section>
      </Inspector.inspector>
    </.demo_section>
    """
  end

  def member(%{member: "separator"} = assigns) do
    ~H"""
    <p>Visual divider — horizontal, labeled, or vertical.</p>
    <.demo_section
      title="Horizontal"
      description="Default full-width rule."
      code={~S'''
      <.separator />
      '''}
    >
      <p style="margin: 0; font-size: .875rem; color: var(--lantern-fg-muted);">Above the line</p>
      <Separator.separator />
      <p style="margin: 0; font-size: .875rem; color: var(--lantern-fg-muted);">Below the line</p>
    </.demo_section>
    <.demo_section
      title="With text"
      description="Centered label on the rule — useful for “or” splits."
      code={~S'''
      <.separator text="or" />
      '''}
    >
      <Separator.separator text="or" />
    </.demo_section>
    <.demo_section
      title="Vertical"
      description="vertical splits adjacent columns."
      code={~S'''
      <.separator vertical />
      '''}
    >
      <div class="docs-row" style="align-items: stretch; gap: 1rem;">
        <p style="margin: 0; font-size: .875rem; color: var(--lantern-fg-muted); max-width: 12rem;">
          Left column with a short note about primary content.
        </p>
        <Separator.separator vertical />
        <p style="margin: 0; font-size: .875rem; color: var(--lantern-fg-muted); max-width: 12rem;">
          Right column for secondary detail or actions.
        </p>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "scroll-area"} = assigns) do
    ~H"""
    <p>Constrain the wrapper to create overflow. A label gives the region keyboard-scrollable semantics with a focusable role=region.</p>
    <.demo_section title="Axes" description="Vertical, horizontal, and both-axis scrolling all use native browser behavior." code={~s"<.scroll_area label=\"Recent activity\" orientation=\"vertical\" style=\"max-height: 8rem\"><p>...</p></.scroll_area>"}>
      <ScrollArea.scroll_area label="Recent activity" orientation="vertical" class="docs-scroll-demo"><p :for={n <- 1..8}>Activity event {n}</p></ScrollArea.scroll_area>
      <ScrollArea.scroll_area label="Timeline" orientation="horizontal" class="docs-scroll-wide"><span :for={n <- 1..8}>Event {n} - </span></ScrollArea.scroll_area>
      <ScrollArea.scroll_area label="Canvas" orientation="both" class="docs-scroll-both"><span :for={n <- 1..5}>Wide content {n} </span></ScrollArea.scroll_area>
    </.demo_section>
    """
  end
end
