defmodule LanternDemoWeb.Docs.Navigation do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "tabs"} = assigns) do
    ~H"""
    <p>
      Segmented or underline tab lists with server-driven active state; tabs given
      <code>patch</code> render as links so tab state can live in the URL.
    </p>
    <.demo_section
      title="Segmented with panels"
      description="Default segmented list; panels show based on the active assign."
      code={~S'''
      <.tabs id="demo-tabs">
        <.tabs_list active_tab={@demo_tab}>
          <:tab name="one" phx-click="demo_tab">First <.badge size="sm">12</.badge></:tab>
          <:tab name="two" phx-click="demo_tab">Second</:tab>
          <:tab name="three" phx-click="demo_tab">Third</:tab>
        </.tabs_list>
        <.tabs_panel name="one" active={@demo_tab == "one"}>First panel content.</.tabs_panel>
        <.tabs_panel name="two" active={@demo_tab == "two"}>Second panel content.</.tabs_panel>
        <.tabs_panel name="three" active={@demo_tab == "three"}>Third panel content.</.tabs_panel>
      </.tabs>
      '''}
    >
      <Tabs.tabs id="demo-tabs">
        <Tabs.tabs_list active_tab={@demo_tab}>
          <:tab name="one" phx-click="demo_tab">
            First <Badge.badge size="sm">12</Badge.badge>
          </:tab>
          <:tab name="two" phx-click="demo_tab">Second</:tab>
          <:tab name="three" phx-click="demo_tab">Third</:tab>
        </Tabs.tabs_list>
        <Tabs.tabs_panel name="one" active={@demo_tab == "one"}>
          First panel content.
        </Tabs.tabs_panel>
        <Tabs.tabs_panel name="two" active={@demo_tab == "two"}>
          Second panel content.
        </Tabs.tabs_panel>
        <Tabs.tabs_panel name="three" active={@demo_tab == "three"}>
          Third panel content.
        </Tabs.tabs_panel>
      </Tabs.tabs>
    </.demo_section>
    <.demo_section
      title="Underline variant"
      description={~s(variant="underline" with size sm — good for page-level tabs.)}
      code={~S'''
      <.tabs_list active_tab="b" variant="underline" size="sm">
        <:tab name="a">Underline</:tab>
        <:tab name="b">Variant</:tab>
      </.tabs_list>
      '''}
    >
      <Tabs.tabs_list active_tab="b" variant="underline" size="sm">
        <:tab name="a">Underline</:tab>
        <:tab name="b">Variant</:tab>
      </Tabs.tabs_list>
    </.demo_section>
    <.demo_section
      title="Segmented"
      description={~s(Standalone pill control with no panels. Give the list an id so LanternTabs handles arrow keys; pass role="radiogroup" when there is no tab panel.)}
      code={~S'''
      <.tabs_list
        id="scope"
        variant="segmented"
        size="sm"
        active_tab={@scope}
        aria-label="View"
        role="radiogroup"
      >
        <:tab name="all" phx-click="set_dense_scope">All</:tab>
        <:tab name="active" phx-click="set_dense_scope">Active</:tab>
        <:tab name="backlog" phx-click="set_dense_scope">Backlog</:tab>
      </.tabs_list>
      '''}
    >
      <Tabs.tabs_list
        id="dense-scope"
        variant="segmented"
        size="sm"
        active_tab={@dense_scope}
        aria-label="View"
        role="radiogroup"
      >
        <:tab name="all" phx-click="set_dense_scope">All</:tab>
        <:tab name="active" phx-click="set_dense_scope">Active</:tab>
        <:tab name="backlog" phx-click="set_dense_scope">Backlog</:tab>
      </Tabs.tabs_list>
    </.demo_section>
    """
  end

  def member(%{member: "breadcrumb"} = assigns) do
    ~H"""
    <p>
      Path navigation for file/tree UIs — a lantern-ui extension. Items render as links,
      event buttons, or the <code>aria-current</code> page.
    </p>
    <.demo_section
      title="Path"
      description="href / navigate / phx-click on intermediate items; current marks the page."
      code={~S'''
      <.breadcrumb>
        <:item href="#">my-bucket</:item>
        <:item href="#">photos</:item>
        <:item href="#">2026</:item>
        <:item current>07-vacation</:item>
      </.breadcrumb>
      '''}
    >
      <Breadcrumb.breadcrumb>
        <:item href="#">my-bucket</:item>
        <:item href="#">photos</:item>
        <:item href="#">2026</:item>
        <:item current>07-vacation</:item>
      </Breadcrumb.breadcrumb>
    </.demo_section>
    """
  end

  def member(%{member: "pagination"} = assigns) do
    ~H"""
    <p>
      Pager + page-size control, duck-typed to <code>Flop.Meta</code> (no flop
      dependency) — all patch navigation. Fluxon has no equivalent; this replaces
      flop_phoenix's pager.
    </p>
    <.demo_section
      title="Basic"
      description="Pass a meta map (current_page, total_pages, page_size, total_count) and a patch_fn."
      code={~S'''
      <.pagination
        meta={%{current_page: 5, total_pages: 20, page_size: 25, total_count: 487}}
        patch_fn={fn p -> ~p"/orders?#{p}" end}
      />
      '''}
    >
      <Pagination.pagination
        id="pg-demo"
        meta={%{current_page: 5, total_pages: 20, page_size: 25, total_count: 487}}
        patch_fn={fn params -> "/docs/navigation/breadcrumb-pagination?" <> Plug.Conn.Query.encode(params) end}
      />
    </.demo_section>
    <.demo_section
      title="Edges & small sets"
      description="Prev is disabled on the first page, next on the last; few pages drop the gaps."
      code={~S'''
      <.pagination meta={%{current_page: 1, total_pages: 8, page_size: 25, total_count: 190}} patch_fn={pf} />
      <.pagination meta={%{current_page: 3, total_pages: 3, page_size: 25, total_count: 62}} patch_fn={pf} />
      '''}
    >
      <div class="docs-row" style="flex-direction: column; align-items: stretch; gap: 1rem;">
        <Pagination.pagination
          id="pg-first"
          meta={%{current_page: 1, total_pages: 8, page_size: 25, total_count: 190}}
          patch_fn={fn params -> "/docs/navigation/breadcrumb-pagination?" <> Plug.Conn.Query.encode(params) end}
        />
        <Pagination.pagination
          id="pg-small"
          meta={%{current_page: 3, total_pages: 3, page_size: 25, total_count: 62}}
          patch_fn={fn params -> "/docs/navigation/breadcrumb-pagination?" <> Plug.Conn.Query.encode(params) end}
        />
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "navlist"} = assigns) do
    ~H"""
    <p>
      Vertical navigation — an optional heading plus links. Items render as
      <code>navigate</code>/<code>patch</code>/<code>href</code> links, or as a
      button when given <code>phx-click</code>. Mirrors Fluxon's navlist surface.
    </p>
    <.demo_section
      title="Headed list"
      description="heading + navlink items; active marks the current page, icon adds a leading glyph."
      code={~S'''
      <.navlist heading="Workspace">
        <.navlink href="#" active>Dashboard</.navlink>
        <.navlink href="#" icon="folder">Projects</.navlink>
        <.navlink href="#" icon="adjustments-horizontal">Settings</.navlink>
        <.navheading>Account</.navheading>
        <.navlink href="#" icon="document">Profile</.navlink>
      </.navlist>
      '''}
    >
      <Navlist.navlist heading="Workspace">
        <Navlist.navlink href="#" active>Dashboard</Navlist.navlink>
        <Navlist.navlink href="#" icon="folder">Projects</Navlist.navlink>
        <Navlist.navlink href="#" icon="adjustments-horizontal">Settings</Navlist.navlink>
        <Navlist.navheading>Account</Navlist.navheading>
        <Navlist.navlink href="#" icon="document">Profile</Navlist.navlink>
      </Navlist.navlist>
    </.demo_section>
    """
  end
end
