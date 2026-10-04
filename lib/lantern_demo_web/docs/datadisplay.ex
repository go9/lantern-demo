defmodule LanternDemoWeb.Docs.DataDisplay do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "table"} = assigns) do
    ~H"""
    <p>
      The presentational family <code>data_table</code> composes — use it directly
      for simple, non-Flop tables.
    </p>
    <.demo_section
      title="Basic"
      description="table_head / table_body / table_row with :col and :cell slots; selected highlights a row."
      code={~S'''
      <.table>
        <.table_head>
          <:col>Name</:col>
          <:col>Role</:col>
          <:col class="lui-th-num">Commits</:col>
        </.table_head>
        <.table_body>
          <.table_row>
            <:cell>Ada Lovelace</:cell>
            <:cell>Analyst</:cell>
            <:cell class="lui-td-num">1,842</:cell>
          </.table_row>
          <.table_row selected>
            <:cell>Grace Hopper</:cell>
            <:cell>Rear Admiral</:cell>
            <:cell class="lui-td-num">2,214</:cell>
          </.table_row>
        </.table_body>
      </.table>
      '''}
    >
      <Table.table>
        <Table.table_head>
          <:col>Name</:col>
          <:col>Role</:col>
          <:col class="lui-th-num">Commits</:col>
        </Table.table_head>
        <Table.table_body>
          <Table.table_row>
            <:cell>Ada Lovelace</:cell>
            <:cell>Analyst</:cell>
            <:cell class="lui-td-num">1,842</:cell>
          </Table.table_row>
          <Table.table_row selected>
            <:cell>Grace Hopper</:cell>
            <:cell>Rear Admiral</:cell>
            <:cell class="lui-td-num">2,214</:cell>
          </Table.table_row>
        </Table.table_body>
      </Table.table>
    </.demo_section>
    """
  end

  def member(%{member: "description-list"} = assigns) do
    ~H"""
    <p>
      Label/value pairs for a record's detail view. <code>layout="stacked"</code>
      (default) puts the label above the value; <code>inline</code> puts it
      alongside; <code>layout="dense"</code> is the inspector-rail grid.
    </p>
    <.demo_section
      title="Stacked"
      description="columns sets how many pairs sit side by side on a wide viewport."
      code={~S'''
      <.description_list>
        <:item label="Created">Jan 4, 2026</:item>
        <:item label="Host">Alex Smith</:item>
        <:item label="Description" wide>Long free text…</:item>
      </.description_list>
      '''}
    >
      <DescriptionList.description_list>
        <:item label="Created">Jan 4, 2026</:item>
        <:item label="Host">Alex Smith</:item>
        <:item label="Description" wide>Long free text…</:item>
      </DescriptionList.description_list>
    </.demo_section>
    <.demo_section
      title="Dense (inspector rail)"
      description={~s(layout="dense" is the label-column + value grid used inside inspector.)}
      code={~S'''
      <.description_list layout="dense">
        <:item label="Repo">enventory_new</:item>
        <:item label="Status">in_progress</:item>
        <:item label="Tags"><.badge size="sm">ui</.badge></:item>
      </.description_list>
      '''}
    >
      <DescriptionList.description_list layout="dense">
        <:item label="Repo">enventory_new</:item>
        <:item label="Status">in_progress</:item>
        <:item label="Tags">
          <Badge.badge size="sm">ui</Badge.badge>
        </:item>
      </DescriptionList.description_list>
    </.demo_section>
    """
  end

  def member(%{member: "resource-list"} = assigns) do
    ~H"""
    <p>Use list rows for compact indexes or grid cards for resource overviews. Linked rows make the whole row the hit target.</p>
    <.demo_section title="List" description="Subtitle, leading content, and trailing metadata compose a linked resource row." code={~s"<.resource_list layout={:list}><.resource_list_item navigate=\"/projects/atlas\" title=\"Atlas\" subtitle=\"atlas\"><.badge>Healthy</.badge></.resource_list_item></.resource_list>"}>
      <ResourceList.resource_list layout={:list}><ResourceList.resource_list_item navigate="/projects/atlas" title="Atlas" subtitle="atlas" subtitle_mono><Badge.badge>Healthy</Badge.badge><span>3 apps</span></ResourceList.resource_list_item><ResourceList.resource_list_item title="Beacon" subtitle="beacon"><Badge.badge color="warning">Review</Badge.badge></ResourceList.resource_list_item></ResourceList.resource_list>
    </.demo_section>
    <.demo_section title="Grid" description="The same item contract becomes cards with layout={:grid}." code={~s"<.resource_list layout={:grid}><.resource_list_item title=\"Atlas\" subtitle=\"atlas\">3 apps</.resource_list_item></.resource_list>"}>
      <ResourceList.resource_list layout={:grid}><ResourceList.resource_list_item title="Atlas" subtitle="atlas" subtitle_mono>3 apps</ResourceList.resource_list_item><ResourceList.resource_list_item title="Beacon" subtitle="beacon">1 app</ResourceList.resource_list_item></ResourceList.resource_list>
    </.demo_section>
    """
  end

  def member(%{member: "list-row"} = assigns) do
    ~H"""
    <p>
      Dense issue/inbox row: leading glyph, muted mono id, truncating title,
      meta, trailing. Lists stay flat — one scroll area, one
      <code>status_glyph</code> column per row, rows ordered by status then
      recency. Whatever a group header would have said (status name, count)
      lives on each row or in the filter chips above the list, with counts.
      Put <code>data-lantern-list-nav</code> on the list and
      <code>data-lantern-list-item</code> on each row for j/k keyboard nav.
    </p>
    <.demo_section
      title="Flat list with status"
      description="Filter chips carry the status names and counts; every row carries its own status glyph. Focus the list, then j/k or arrows move the ring. Enter follows the row link."
      code={~S'''
      <div class="docs-row">
        <.badge size="sm">All (3)</.badge>
        <.badge size="sm">In progress (1)</.badge>
        <.badge size="sm">To do (1)</.badge>
        <.badge size="sm">Done (1)</.badge>
      </div>
      <.scroll_area label="Tickets" data-lantern-list-nav>
        <.list_row
          identifier="#241"
          title="Visible progress ring"
          parent="Dense primitives"
          href="/docs/data-display/tables-lists"
          selected
          data-lantern-list-item
        >
          <:leading>
            <.priority_glyph priority={:high} />
            <.status_glyph status={:in_progress} />
          </:leading>
          <:meta><.badge size="sm">ui</.badge></:meta>
          <:trailing>Sep 3</:trailing>
        </.list_row>
        <.list_row
          identifier="#238"
          title="Inspector rail"
          href="/docs/layout/panels"
          data-lantern-list-item
        >
          <:leading><.status_glyph status={:todo} /></:leading>
          <:meta><.badge size="sm">docs</.badge></:meta>
          <:trailing>Sep 1</:trailing>
        </.list_row>
        <.list_row
          identifier="#199"
          title="Closed ring"
          href="/docs/foundations/status"
          data-lantern-list-item
        >
          <:leading><.status_glyph status={:done} /></:leading>
          <:trailing>Aug 28</:trailing>
        </.list_row>
      </.scroll_area>
      '''}
    >
      <div class="docs-row">
        <Badge.badge size="sm">All (3)</Badge.badge>
        <Badge.badge size="sm">In progress (1)</Badge.badge>
        <Badge.badge size="sm">To do (1)</Badge.badge>
        <Badge.badge size="sm">Done (1)</Badge.badge>
      </div>
      <ScrollArea.scroll_area label="Tickets" data-lantern-list-nav>
        <ListRow.list_row
          identifier="#241"
          title="Visible progress ring"
          parent="Dense primitives"
          href="/docs/data-display/tables-lists"
          selected
          data-lantern-list-item
        >
          <:leading>
            <StateGlyph.priority_glyph priority={:high} />
            <StateGlyph.status_glyph status={:in_progress} />
          </:leading>
          <:meta>
            <Badge.badge size="sm">ui</Badge.badge>
          </:meta>
          <:trailing>Sep 3</:trailing>
        </ListRow.list_row>
        <ListRow.list_row
          identifier="#238"
          title="Inspector rail"
          href="/docs/layout/panels"
          data-lantern-list-item
        >
          <:leading>
            <StateGlyph.status_glyph status={:todo} />
          </:leading>
          <:meta>
            <Badge.badge size="sm">docs</Badge.badge>
          </:meta>
          <:trailing>Sep 1</:trailing>
        </ListRow.list_row>
        <ListRow.list_row
          identifier="#199"
          title="Closed ring"
          href="/docs/foundations/status"
          data-lantern-list-item
        >
          <:leading>
            <StateGlyph.status_glyph status={:done} />
          </:leading>
          <:trailing>Aug 28</:trailing>
        </ListRow.list_row>
      </ScrollArea.scroll_area>
    </.demo_section>
    """
  end

  def member(%{member: "stat"} = assigns) do
    ~H"""
    <p>
      Compact summary metrics extracted from the data-table overview. Use
      <code>stat_card/1</code> alone or compose a responsive group with
      <code>stat_grid/1</code>. Callers own calculations, formatting, trends, and
      navigation state.
    </p>
    <.demo_section
      title="Standalone metric"
      description="Without href the card is a non-interactive div; subtitle adds quiet context."
      code={~S'''
      <.stat_card
        label="Queued jobs"
        value={18}
        subtitle="4 require attention"
        icon="hero-inbox"
      />
      '''}
    >
      <div style="max-width: 18rem;">
        <Stat.stat_card
          label="Queued jobs"
          value={18}
          subtitle="4 require attention"
          icon="hero-inbox"
        />
      </div>
    </.demo_section>

    <.demo_section
      title="Responsive grid"
      description="Cards share a minimum basis, wrap without caller breakpoints, and only become links when href is present."
      code={~S'''
      <.stat_grid aria-label="Order summary">
        <:stat label="Open orders" value={42} />
        <:stat label="Shipped" value={128} href={~p"/orders?status=shipped"} />
        <:stat label="Long value" value="pending-warehouse-confirmation-2026-07" />
        <:stat label="Revenue" value="$12,482.19" subtitle="Last 30 days" />
      </.stat_grid>
      '''}
    >
      <Stat.stat_grid aria-label="Order summary">
        <:stat label="Open orders" value={42} />
        <:stat label="Shipped" value={128} href="/docs/data-display/data-table" />
        <:stat label="Long value" value="pending-warehouse-confirmation-2026-07" />
        <:stat label="Revenue" value="$12,482.19" subtitle="Last 30 days" />
      </Stat.stat_grid>
    </.demo_section>
    """
  end

  def member(%{member: "area-chart"} = assigns) do
    ~H"""
    <p>
      Server-rendered SVG — geometry computed in Elixir, one hover hook, no chart
      library. Catmull-Rom smoothing under a density threshold.
    </p>
    <div class="docs-demo">
      <Charts.area_chart id="ch-area" series={@area} height={220} value_format={:currency} />
    </div>
    <.code_block id="code-area-chart" code={@snippets["area-chart"]} />
    """
  end

  def member(%{member: "line-chart"} = assigns) do
    ~H"""
    <p>Multi-series line chart with a shared crosshair + tooltip and a legend.</p>
    <div class="docs-demo">
      <Charts.line_chart id="ch-line" series={@line} height={220} />
    </div>
    <.code_block id="code-line-chart" code={@snippets["line-chart"]} />
    """
  end

  def member(%{member: "bar-chart"} = assigns) do
    ~H"""
    <p>Categorical bars with value labels.</p>
    <div class="docs-demo">
      <Charts.bar_chart id="ch-bar" series={@bars} height={200} />
    </div>
    <.code_block id="code-bar-chart" code={@snippets["bar-chart"]} />
    """
  end

  def member(%{member: "sparkline"} = assigns) do
    ~H"""
    <p>Tiny inline trend line — no axes, no hooks.</p>
    <div class="docs-demo">
      <div class="docs-spark-box">
        <Charts.sparkline id="ch-spark" series={[3, 5, 4, 8, 6, 9]} height={48} />
      </div>
    </div>
    <.code_block id="code-sparkline" code={@snippets["sparkline"]} />
    """
  end

  def member(%{member: "accordion"} = assigns) do
    ~H"""
    <p>
      WAI-ARIA disclosure groups with Fluxon 2.3.1's
      <code>accordion/1</code> + <code>accordion_item/1</code> composition API.
      Arrow keys move between headers; Enter and Space toggle the focused item.
    </p>
    <.demo_section
      title="Required open item"
      description="Single-open mode with prevent_all_closed keeps one answer available at all times."
      code={~S'''
      <.accordion id="faq" prevent_all_closed>
        <.accordion_item id="faq-search" expanded>
          <:header>Who owns async search?</:header>
          <:panel>The LiveView owns querying and authorization.</:panel>
        </.accordion_item>
        <.accordion_item id="faq-state">
          <:header>Does state survive patches?</:header>
          <:panel>Yes. Hook-owned state is restored after LiveView patches.</:panel>
        </.accordion_item>
      </.accordion>
      '''}
    >
      <Accordion.accordion id="faq" prevent_all_closed>
        <Accordion.accordion_item id="faq-search" expanded>
          <:header>Who owns async search?</:header>
          <:panel>
            The LiveView owns querying, authorization, and ordering; the component owns interaction.
          </:panel>
        </Accordion.accordion_item>
        <Accordion.accordion_item id="faq-state">
          <:header>Does state survive LiveView patches?</:header>
          <:panel>Yes. Open state and focused-header position are restored after patches.</:panel>
        </Accordion.accordion_item>
        <Accordion.accordion_item id="faq-keyboard">
          <:header>Which keys are supported?</:header>
          <:panel>Enter, Space, Arrow Up/Down, Home, and End follow the APG pattern.</:panel>
        </Accordion.accordion_item>
      </Accordion.accordion>
    </.demo_section>

    <.demo_section
      title="Multiple open"
      description="multiple allows independent disclosure panels; icon={false} supports a custom visual treatment."
      code={~S'''
      <.accordion id="details" multiple>
        <.accordion_item id="details-api" expanded>
          <:header>Public API</:header>
          <:panel>Fluxon-compatible container and item functions.</:panel>
        </.accordion_item>
        <.accordion_item id="details-license" expanded icon={false}>
          <:header>Implementation</:header>
          <:panel>Independent, clean-room Lantern behavior.</:panel>
        </.accordion_item>
      </.accordion>
      '''}
    >
      <Accordion.accordion id="details" multiple>
        <Accordion.accordion_item id="details-api" expanded>
          <:header>Public API</:header>
          <:panel>Fluxon-compatible container and item functions.</:panel>
        </Accordion.accordion_item>
        <Accordion.accordion_item id="details-license" expanded icon={false}>
          <:header>Implementation</:header>
          <:panel>Independent, clean-room Lantern behavior.</:panel>
        </Accordion.accordion_item>
      </Accordion.accordion>
    </.demo_section>
    """
  end

  def member(%{member: "timeline"} = assigns) do
    ~H"""
    <p>
      Vertical event sequence with a marker rail:
      <code>timeline/1</code> plus <code>timeline_item/1</code>. Ordered list markup;
      pure server render, no JS hook.
    </p>
    <.demo_section
      title="Basic"
      description="Three items with status :done / :active / :pending plus label, at, and title. The state word always renders, so items stay legible in grayscale."
      code={~S'''
      <.timeline>
        <.timeline_item status={:done} label="Deployed" at="2h ago" title="enventory" />
        <.timeline_item status={:active} label="Deploying" at="40s" title="foodfeed" />
        <.timeline_item status={:pending} label="Queued" at="just now" title="skusync" />
      </.timeline>
      '''}
    >
      <Timeline.timeline>
        <Timeline.timeline_item status={:done} label="Deployed" at="2h ago" title="enventory" />
        <Timeline.timeline_item status={:active} label="Deploying" at="40s" title="foodfeed" />
        <Timeline.timeline_item status={:pending} label="Queued" at="just now" title="skusync" />
      </Timeline.timeline>
    </.demo_section>
    <.demo_section
      title="Statuses"
      description="One item per status, including :danger and :neutral."
      code={~S'''
      <.timeline>
        <.timeline_item status={:done} label="Deployed" title="done" />
        <.timeline_item status={:active} label="Deploying" title="active" />
        <.timeline_item status={:pending} label="Queued" title="pending" />
        <.timeline_item status={:danger} label="Failed" title="danger" />
        <.timeline_item status={:neutral} label="Note" title="neutral" />
      </.timeline>
      '''}
    >
      <Timeline.timeline>
        <Timeline.timeline_item status={:done} label="Deployed" title="done" />
        <Timeline.timeline_item status={:active} label="Deploying" title="active" />
        <Timeline.timeline_item status={:pending} label="Queued" title="pending" />
        <Timeline.timeline_item status={:danger} label="Failed" title="danger" />
        <Timeline.timeline_item status={:neutral} label="Note" title="neutral" />
      </Timeline.timeline>
    </.demo_section>
    <.demo_section
      title="Collapsible detail"
      description="Deployment-log shape: title is the summary, :detail is the output. open starts expanded."
      code={~S'''
      <.timeline>
        <.timeline_item status={:done} label="Deployed" at="2h ago" title="enventory">
          <:detail>
            <pre>==> Building release
      Compiling 8 files (.ex)
      Generated enventory app
      ==> Deployed to production</pre>
          </:detail>
        </.timeline_item>
        <.timeline_item status={:active} label="Deploying" at="40s" title="foodfeed" open>
          <:detail>
            <pre>==> Building release
      Compiling 12 files (.ex)
      Generated foodfeed app</pre>
          </:detail>
        </.timeline_item>
      </.timeline>
      '''}
    >
      <Timeline.timeline>
        <Timeline.timeline_item status={:done} label="Deployed" at="2h ago" title="enventory">
          <:detail>
            <pre>==> Building release
      Compiling 8 files (.ex)
      Generated enventory app
      ==> Deployed to production</pre>
          </:detail>
        </Timeline.timeline_item>
        <Timeline.timeline_item status={:active} label="Deploying" at="40s" title="foodfeed" open>
          <:detail>
            <pre>==> Building release
      Compiling 12 files (.ex)
      Generated foodfeed app</pre>
          </:detail>
        </Timeline.timeline_item>
      </Timeline.timeline>
    </.demo_section>
    <.demo_section
      title="Leading labels"
      description="label_position={:leading} on the container places timestamps in their own column; items inherit it."
      code={~S'''
      <.timeline label_position={:leading}>
        <.timeline_item status={:done} label="Deployed" at="2h ago" title="enventory" />
        <.timeline_item status={:active} label="Deploying" at="40s" title="foodfeed" />
        <.timeline_item status={:pending} label="Queued" at="just now" title="skusync" />
      </.timeline>
      '''}
    >
      <Timeline.timeline label_position={:leading}>
        <Timeline.timeline_item status={:done} label="Deployed" at="2h ago" title="enventory" />
        <Timeline.timeline_item status={:active} label="Deploying" at="40s" title="foodfeed" />
        <Timeline.timeline_item status={:pending} label="Queued" at="just now" title="skusync" />
      </Timeline.timeline>
    </.demo_section>
    <.demo_section
      title="Marker slot"
      description=":marker replaces the status dot or icon. Avatars and other custom glyphs are supported."
      code={~S'''
      <.timeline>
        <.timeline_item status={:done} label="Merged" at="3h ago" title="PR #412">
          <:marker>
            <span class="docs-timeline-avatar">GO</span>
          </:marker>
        </.timeline_item>
        <.timeline_item status={:active} label="Reviewing" at="12m" title="PR #418">
          <:marker>
            <span class="docs-timeline-avatar">AL</span>
          </:marker>
        </.timeline_item>
        <.timeline_item status={:pending} label="Queued" at="just now" title="PR #421" />
      </.timeline>
      '''}
    >
      <Timeline.timeline>
        <Timeline.timeline_item status={:done} label="Merged" at="3h ago" title="PR #412">
          <:marker>
            <span class="docs-timeline-avatar">GO</span>
          </:marker>
        </Timeline.timeline_item>
        <Timeline.timeline_item status={:active} label="Reviewing" at="12m" title="PR #418">
          <:marker>
            <span class="docs-timeline-avatar">AL</span>
          </:marker>
        </Timeline.timeline_item>
        <Timeline.timeline_item status={:pending} label="Queued" at="just now" title="PR #421" />
      </Timeline.timeline>
    </.demo_section>
    """
  end
end
