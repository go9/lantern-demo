defmodule LanternDemoWeb.BlocksLive do
  @moduledoc """
  Review showcase: the eight lantern-ui page blocks, live.

  HEEx is copied from `test/support/blocks/*.html.heex` at the pinned
  lantern-ui ref (see `docs/recipes.md` there), with the fixture assigns
  copied below and wired to real LiveView state where trivial: the list
  block filters/searches/paginates through the URL (the data_table's own
  chrome), the dashboard chips filter activity, the detail panel toggles,
  and the form/settings/login/destructive blocks answer their buttons
  (validation errors or demo toasts — nothing leaves the browser).
  """
  use Phoenix.LiveView
  use LanternUI

  alias LanternDemoWeb.DocsShell

  @blocks ~w(app-shell dashboard list detail settings form login destructive)

  @labels %{
    "app-shell" => "App shell",
    "dashboard" => "Dashboard",
    "list" => "List",
    "detail" => "Detail + inspector",
    "settings" => "Settings",
    "form" => "Form",
    "login" => "Login",
    "destructive" => "Destructive flow"
  }

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Blocks — lantern-ui")
     |> assign(:labels, @labels)
     |> assign(:block, "dashboard")
     |> assign(:activity_filter, "all")
     |> assign(:panel_open, true)
     |> assign(:confirm_open, false)
     |> assign(:ticket_form, %{"title" => "", "body" => "", "status" => ""})
     |> assign(:ticket_errors, %{})
     |> assign_fixtures()}
  end

  def handle_params(%{"name" => name} = params, _uri, socket) when name in @blocks do
    socket =
      socket
      |> assign(:block, name)
      |> assign(:page_title, "#{Map.fetch!(@labels, name)} block — lantern-ui")

    socket =
      if name == "list" do
        socket
        |> assign(:list_params, Map.drop(params, ["name"]))
        |> assign_list(socket.assigns.tickets)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, push_navigate(socket, to: "/blocks/dashboard")}
  end

  # ── list block: the data_table's chrome (filter/search/pagination) drives
  # the URL; honor its Flop-ish params server-side. ──

  defp assign_list(socket, tickets) do
    params = Map.get(socket.assigns, :list_params, %{})
    {rows, meta} = filter_table(tickets, params)
    assign(socket, list_rows: rows, list_meta: meta)
  end

  defp filter_table(tickets, params) do
    filters =
      params
      |> Map.get("filters", %{})
      |> Map.values()
      |> Enum.filter(&is_map/1)

    status =
      Enum.find_value(filters, fn
        %{"field" => "status", "value" => v} when v not in [nil, ""] -> v
        _ -> nil
      end)

    query =
      Enum.find_value(filters, fn
        %{"field" => "title", "value" => v} when v not in [nil, ""] -> v
        _ -> nil
      end)

    rows =
      tickets
      |> then(fn rs ->
        if status, do: Enum.filter(rs, &(to_string(&1.status) == status)), else: rs
      end)
      |> then(fn rs ->
        if query do
          q = String.downcase(query)
          Enum.filter(rs, &String.contains?(String.downcase(&1.title), q))
        else
          rs
        end
      end)

    page = parse_int(params["page"], 1)
    page_size = parse_int(params["page_size"], 10)
    total = length(rows)
    total_pages = max(1, ceil(total / page_size))
    page = min(max(page, 1), total_pages)

    meta = %{
      params: params,
      current_page: page,
      total_pages: total_pages,
      page_size: page_size,
      total_count: total
    }

    {Enum.slice(rows, (page - 1) * page_size, page_size), meta}
  end

  defp parse_int(nil, default), do: default

  defp parse_int(value, default) do
    case Integer.parse(to_string(value)) do
      {n, _} when n > 0 -> n
      _ -> default
    end
  end

  # ── dashboard activity chips, destructive confirm, settings, login ──

  def handle_event("filter_activity", %{"status" => status}, socket) do
    {:noreply, assign(socket, :activity_filter, status)}
  end

  def handle_event("open_confirm", _params, socket) do
    {:noreply, assign(socket, :confirm_open, true)}
  end

  def handle_event("close_confirm", _params, socket) do
    {:noreply, assign(socket, :confirm_open, false)}
  end

  def handle_event("confirm_delete", _params, socket) do
    {:noreply,
     socket
     |> assign(:confirm_open, false)
     |> LanternUI.send_toast(:warning, "Nothing was harmed — this is a demo.",
       title: "Deleted (demo)"
     )}
  end

  # ── settings saves ──

  def handle_event("save_profile", _params, socket) do
    {:noreply,
     LanternUI.send_toast(socket, :success, "Display name and email kept (demo).",
       title: "Profile saved"
     )}
  end

  def handle_event("save_notifications", _params, socket) do
    {:noreply,
     LanternUI.send_toast(socket, :success, "Notification picks kept (demo).",
       title: "Notifications saved"
     )}
  end

  def handle_event("save_appearance", _params, socket) do
    {:noreply,
     LanternUI.send_toast(socket, :success, "Theme and signature kept (demo).",
       title: "Appearance saved"
     )}
  end

  # ── login ──

  def handle_event("demo_login", _params, socket) do
    {:noreply,
     LanternUI.send_toast(socket, :info, "No credentials leave the browser.",
       title: "Demo only — not signed in"
     )}
  end

  def handle_event("demo_sso", _params, socket) do
    {:noreply,
     LanternUI.send_toast(socket, :info, "SSO is not wired in the demo.", title: "Demo only")}
  end

  # ── new-ticket form: inline errors, toast on success ──

  def handle_event("save_ticket", %{"ticket" => ticket_params}, socket) do
    title = String.trim(Map.get(ticket_params, "title", ""))
    status = Map.get(ticket_params, "status", "")

    errors =
      %{}
      |> then(fn e -> if title == "", do: Map.put(e, "title", ["can't be blank"]), else: e end)
      |> then(fn e -> if status == "", do: Map.put(e, "status", ["can't be blank"]), else: e end)

    if errors == %{} do
      {:noreply,
       socket
       |> assign(:ticket_form, %{"title" => "", "body" => "", "status" => ""})
       |> assign(:ticket_errors, %{})
       |> LanternUI.send_toast(:success, "“#{title}” filed as #242 (demo).",
         title: "Ticket created"
       )}
    else
      {:noreply,
       socket
       |> assign(:ticket_form, ticket_params)
       |> assign(:ticket_errors, errors)}
    end
  end

  # ── fixtures (copied from LanternUI.Blocks.fixture_assigns at the pin) ──

  defp filtered_activity(assigns) do
    case assigns.activity_filter do
      "all" -> assigns.activity
      status -> Enum.filter(assigns.activity, &(to_string(&1.status) == status))
    end
  end

  defp assign_fixtures(socket) do
    assign(socket,
      shell_crumbs: [
        %{label: "Acme", path: "/"},
        %{label: "Tickets", path: nil}
      ],
      detail_crumbs: [
        %{label: "Tickets", path: "/blocks/list"},
        %{label: "#241", path: nil}
      ],
      form_crumbs: [
        %{label: "Tickets", path: "/blocks/list"},
        %{label: "New", path: nil}
      ],
      ticket: %{
        title: "Visible progress ring",
        identifier: "#241",
        body: "Extract the ring from flicker so 7/19 stays visible on the hub.",
        status: :in_progress,
        priority: :high,
        tag: "ui",
        completed: 7,
        scope: 19
      },
      tickets: [
        %{
          id: 241,
          title: "Visible progress ring",
          identifier: "#241",
          parent: "Dense primitives",
          href: "/blocks/detail",
          status: :in_progress,
          tag: "ui",
          date: "Sep 3",
          selected: false
        },
        %{
          id: 240,
          title: "Extract eight primitives",
          identifier: "#240",
          parent: nil,
          href: "/blocks/detail",
          status: :todo,
          tag: "ui",
          date: "Sep 2",
          selected: false
        },
        %{
          id: 239,
          title: "Hub dashboard grouping",
          identifier: "#239",
          parent: nil,
          href: "/blocks/detail",
          status: :done,
          tag: "ui",
          date: "Aug 28",
          selected: false
        }
      ],
      list_rows: [],
      list_meta: %{params: %{}, current_page: 1, total_pages: 1, page_size: 10, total_count: 3},
      list_params: %{},
      stats: [
        %{label: "Open tickets", value: "128", subtitle: "+12 this week"},
        %{label: "In progress", value: "34", subtitle: "8 owners"},
        %{label: "Merged today", value: "19", subtitle: "across 4 repos"},
        %{label: "P95 review lag", value: "3.2h", subtitle: "-0.4h vs last week"}
      ],
      series: [
        %{date: "2026-09-20", value: 4},
        %{date: "2026-09-21", value: 7},
        %{date: "2026-09-22", value: 5},
        %{date: "2026-09-23", value: 9},
        %{date: "2026-09-24", value: 12},
        %{date: "2026-09-25", value: 8},
        %{date: "2026-09-26", value: 11},
        %{date: "2026-09-27", value: 14},
        %{date: "2026-09-28", value: 10},
        %{date: "2026-09-29", value: 13},
        %{date: "2026-09-30", value: 16},
        %{date: "2026-10-01", value: 12},
        %{date: "2026-10-02", value: 15},
        %{date: "2026-10-03", value: 19}
      ],
      activity: [
        %{
          identifier: "#241",
          title: "Visible progress ring",
          href: "/blocks/detail",
          status: :in_progress,
          date: "2h ago"
        },
        %{
          identifier: "#240",
          title: "Extract eight primitives",
          href: "/blocks/detail",
          status: :todo,
          date: "5h ago"
        },
        %{
          identifier: "#239",
          title: "Hub dashboard grouping",
          href: "/blocks/detail",
          status: :done,
          date: "1d ago"
        }
      ]
    )
  end

  # ── render ──

  def render(%{block: "app-shell"} = assigns) do
    ~H"""
    <.theme />
    <.toast_group id="blocks-toasts" flash={@flash} />
    <.app_shell id="demo-app">
      <:brand>
        <.icon name="sparkles" />
        <span class="lui-brand-name">Acme</span>
      </:brand>
      <:header>
        <.badge size="sm" variant="soft">Production</.badge>
      </:header>
      <:actions>
        <.avatar size="sm" initials="AL" />
      </:actions>
      <:breadcrumb>
        <.breadcrumb home="/" items={@shell_crumbs} />
      </:breadcrumb>
      <:sidebar>
        <.nav_group label="Workspace">
          <.nav_item label="Dashboard" icon="chart-bar" navigate="/blocks/dashboard" />
          <.nav_item label="Tickets" icon="document" navigate="/blocks/list" badge={12} active />
          <.nav_item label="Inbox" icon="inbox" navigate="/blocks/list" badge={3} />
        </.nav_group>
        <.nav_group label="Manage">
          <.nav_item label="Projects" icon="folder" navigate="/blocks/detail" />
          <.nav_item label="Settings" icon="adjustments-horizontal" navigate="/blocks/settings" />
        </.nav_group>
      </:sidebar>
      <:sidebar_footer>
        <.nav_link label="Documentation" icon="globe-alt" href="/docs/blocks" />
      </:sidebar_footer>
      <div id="review-bar" phx-hook="DemoChrome" data-shell="demo-app" class="blocks-reviewbar">
        <.link navigate="/docs/blocks" class="blocks-reviewbar-back">← Blocks</.link>
        <span class="blocks-reviewbar-title">App shell block — the chrome on this page is the recipe</span>
        <span class="demo-chrome">
          <.button variant="outline" size="sm" type="button" data-part="theme-toggle">
            <span data-part="theme-label">Dark</span>
          </.button>
          <.button variant="outline" size="sm" type="button" data-part="density-toggle">
            <span data-part="density-label">Compact</span>
          </.button>
          <.button variant="outline" size="sm" type="button" data-part="preset-toggle">
            <span data-part="preset-label">Default</span>
          </.button>
        </span>
      </div>
      <.page_header title="Tickets" description="Every request, one flat list.">
        <:actions>
          <.button size="sm" variant="solid" navigate="/blocks/form">New ticket</.button>
        </:actions>
      </.page_header>
      <.card title="Getting started" description="Three steps to a finished page.">
        <p style="margin: 0;">
          Pick a block from the recipe index, swap the fixture assigns for the host LiveView assigns, and ship.
        </p>
        <:footer>Blocks render in the default theme and the shadcn preset — flip the switch up top.</:footer>
      </.card>
    </.app_shell>
    <style>
      .blocks-reviewbar { position: sticky; top: 0; z-index: 10; display: flex; align-items: center;
        gap: 0.75rem; margin: 0 -1.5rem 1.25rem; padding: 0.5rem 1.5rem;
        background: var(--lantern-surface); border-bottom: 1px solid var(--lantern-border); }
      .blocks-reviewbar-back { font-size: 0.82rem; font-weight: 600; text-decoration: none;
        color: var(--lantern-fg-muted); }
      .blocks-reviewbar-back:hover { color: var(--lantern-fg); }
      .blocks-reviewbar-title { font-size: 0.82rem; color: var(--lantern-fg-muted); flex: 1; }
      .blocks-reviewbar .demo-chrome { display: inline-flex; gap: 0.4rem; }
    </style>
    """
  end

  def render(assigns) do
    ~H"""
    <DocsShell.shell current={"blocks/#{@block}"}>
      <.toast_group id="blocks-toasts" flash={@flash} />
      <h1 :if={@block in ["list", "form"]} class="lui-sr-only">{Map.fetch!(@labels, @block)} block</h1>
      <article :if={@block == "dashboard"} class="docs-body docs-body-wide">
        <p class="docs-eyebrow">Block · copied from lantern-ui recipes</p>
        <div style="max-width: 1120px; margin: 0 auto;">
          <.stack gap="lg">
            <.page_header title="Dashboard" description="Where the week stands at a glance.">
              <:actions>
                <.button size="sm" variant="outline">Export</.button>
                <.button size="sm" variant="solid" navigate="/blocks/form">New ticket</.button>
              </:actions>
            </.page_header>
            <.stat_grid>
              <:stat :for={stat <- @stats} label={stat.label} value={stat.value} subtitle={stat.subtitle} />
            </.stat_grid>
            <.card title="Merged per day" description="Last 14 days across 4 repos.">
              <.area_chart
                id="dashboard-merged"
                series={@series}
                height={220}
                aria_label="Merged tickets per day"
              />
            </.card>
            <.card flush title="Recent activity" description="Latest updates, most recent first.">
              <:actions>
                <div class="docs-row">
                  <.button
                    :for={s <- ~w(all in_progress todo done)}
                    size="sm"
                    variant={if @activity_filter == s, do: "solid", else: "outline"}
                    phx-click="filter_activity"
                    phx-value-status={s}
                  >
                    {s |> String.replace("_", " ") |> String.capitalize()}
                  </.button>
                </div>
              </:actions>
              <.list_row
                :for={item <- filtered_activity(assigns)}
                identifier={item.identifier}
                title={item.title}
                navigate={item.href}
              >
                <:leading><.status_glyph status={item.status} /></:leading>
                <:trailing>{item.date}</:trailing>
              </.list_row>
            </.card>
          </.stack>
        </div>
      </article>

      <article :if={@block == "list"} class="docs-body docs-body-wide">
        <p class="docs-eyebrow">Block · copied from lantern-ui recipes</p>
        <div style="max-width: 1120px; margin: 0 auto;">
          <.stack gap="lg">
            <.breadcrumb_bar id="tickets-crumb">
              <.breadcrumb home="/" items={@shell_crumbs} />
              <:actions label="New ticket" navigate="/blocks/form">
                <.button size="sm" variant="solid" navigate="/blocks/form">New ticket</.button>
              </:actions>
            </.breadcrumb_bar>
            <div style="height: 640px; display: flex; flex-direction: column;">
              <.data_table
                id="tickets"
                rows={@list_rows}
                meta={@list_meta}
                path="/blocks/list"
                fill
                views={["list"]}
                show_checkboxes={false}
                search_field={:title}
                row_navigate={& &1.href}
                data-lantern-list-nav
              >
                <:tab label="All" count={24} />
                <:tab label="In progress" count={9} filters={[%{field: "status", value: "in_progress"}]} />
                <:tab label="To do" count={11} filters={[%{field: "status", value: "todo"}]} />
                <:tab label="Done" count={4} filters={[%{field: "status", value: "done"}]} />
                <:filter
                  field={:status}
                  label="Status"
                  options={[
                    {"In progress (9)", "in_progress"},
                    {"To do (11)", "todo"},
                    {"Done (4)", "done"}
                  ]}
                  prompt="All statuses"
                />
                <:list_item :let={ticket}>
                  <.list_row
                    identifier={ticket.identifier}
                    title={ticket.title}
                    parent={ticket.parent}
                    selected={ticket.selected}
                    data-lantern-list-item
                  >
                    <:leading>
                      <.status_glyph status={ticket.status} />
                      <span class="lui-list-row-status">
                        {ticket.status |> Atom.to_string() |> String.replace("_", " ")}
                      </span>
                    </:leading>
                    <:meta>
                      <.badge size="sm">{ticket.tag}</.badge>
                    </:meta>
                    <:trailing>{ticket.date}</:trailing>
                  </.list_row>
                </:list_item>
                <:empty>
                  <.empty_state icon="document" title="No tickets match">
                    Try a different search, or create the first ticket.
                    <:action>
                      <.button size="sm" variant="solid" navigate="/blocks/form">New ticket</.button>
                    </:action>
                  </.empty_state>
                </:empty>
              </.data_table>
            </div>
          </.stack>
        </div>
      </article>

      <article :if={@block == "detail"} class="docs-body docs-body-wide">
        <p class="docs-eyebrow">Block · copied from lantern-ui recipes</p>
        <div style="max-width: 1120px; margin: 0 auto;">
          <.stack gap="lg">
            <.breadcrumb_bar id="ticket-crumb">
              <.breadcrumb home="/" items={@detail_crumbs} />
              <:actions label="Toggle panel">
                <.side_panel_toggle
                  id="ticket-panel-toggle"
                  panel_id="ticket-panel"
                  panel_key="ticket"
                  open={@panel_open}
                  kbd="]"
                />
              </:actions>
              <:actions label="Edit ticket" navigate="/blocks/form">
                <.button size="sm" variant="outline" navigate="/blocks/form">Edit</.button>
              </:actions>
            </.breadcrumb_bar>
            <.page_header title={@ticket.title} description={@ticket.identifier} />
            <div style="display: flex; gap: 1.25rem; align-items: flex-start;">
              <.card title="Description" style="flex: 1; min-width: 0;">
                {@ticket.body}
                <:footer>
                  <.progress
                    shape="ring"
                    completed={@ticket.completed}
                    scope={@ticket.scope}
                    size="sm"
                    label="Completion"
                  >
                    {@ticket.completed} / {@ticket.scope}
                  </.progress>
                </:footer>
              </.card>
              <.side_panel id="ticket-panel" open={@panel_open} aria-label="Ticket properties">
                <.inspector aria-label="Ticket">
                  <.inspector_section title="Properties">
                    <.description_list layout="dense">
                      <:item label="Status">
                        <.status_glyph status={@ticket.status} /> in progress
                      </:item>
                      <:item label="Priority">
                        <.priority_glyph priority={@ticket.priority} /> high
                      </:item>
                      <:item label="Tags">
                        <.badge size="sm">{@ticket.tag}</.badge>
                      </:item>
                    </.description_list>
                  </.inspector_section>
                  <.inspector_section title="People">
                    <.description_list layout="dense">
                      <:item label="Owner">Ada Lovelace</:item>
                      <:item label="Reviewer">Grace Hopper</:item>
                    </.description_list>
                  </.inspector_section>
                </.inspector>
              </.side_panel>
            </div>
          </.stack>
        </div>
      </article>

      <article :if={@block == "settings"} class="docs-body docs-body-wide">
        <p class="docs-eyebrow">Block · copied from lantern-ui recipes</p>
        <div style="max-width: 760px; margin: 0 auto;">
          <.stack gap="lg">
            <.page_header
              title="Settings"
              description="Each section saves on its own — nothing else moves."
            />
            <.card title="Profile" description="How your name appears on tickets and reviews.">
              <.stack gap="md">
                <.input id="settings-name" name="name" label="Display name" value="Ada Lovelace" />
                <.input
                  id="settings-email"
                  name="email"
                  type="email"
                  label="Email"
                  value="ada@acme.test"
                  help_text="Receipts and review requests land here."
                />
              </.stack>
              <:footer>
                <span>Saved 2m ago</span>
                <.button size="sm" variant="solid" phx-click="save_profile">Save profile</.button>
              </:footer>
            </.card>
            <.card title="Notifications" description="Pick which pings are worth interrupting you.">
              <.stack gap="sm">
                <.switch id="settings-mentions" name="mentions" label="Mentions" checked value="true" />
                <.switch
                  id="settings-review"
                  name="review_requests"
                  label="Review requests"
                  checked
                  value="true"
                />
                <.switch id="settings-weekly" name="weekly_digest" label="Weekly digest" value="false" />
              </.stack>
              <:footer>
                <span>Saved 1h ago</span>
                <.button size="sm" variant="solid" phx-click="save_notifications">Save notifications</.button>
              </:footer>
            </.card>
            <.card title="Appearance" description="Density and theme for this workspace.">
              <.stack gap="md">
                <.select
                  native
                  id="settings-theme"
                  name="theme"
                  label="Theme"
                  options={[{"System", "system"}, {"Light", "light"}, {"Dark", "dark"}]}
                  value="system"
                  prompt="Pick a theme"
                />
                <.textarea
                  id="settings-signature"
                  name="signature"
                  label="Review signature"
                  value="Ship it."
                  help_text="Appended to approvals you write."
                />
              </.stack>
              <:footer>
                <span>Saved yesterday</span>
                <.button size="sm" variant="solid" phx-click="save_appearance">Save appearance</.button>
              </:footer>
            </.card>
          </.stack>
        </div>
      </article>

      <article :if={@block == "form"} class="docs-body docs-body-wide">
        <p class="docs-eyebrow">Block · copied from lantern-ui recipes</p>
        <div style="max-width: 760px; margin: 0 auto;">
          <.stack gap="lg">
            <.breadcrumb_bar id="ticket-new-crumb">
              <.breadcrumb home="/" items={@form_crumbs} />
            </.breadcrumb_bar>
            <.card title="New ticket" description="Small, sharp titles get picked up fastest.">
              <form phx-submit="save_ticket" id="ticket-form" style="display: contents;">
                <.stack gap="md">
                  <.alert
                    :if={@ticket_errors != %{}}
                    color="danger"
                    title="2 problems need attention"
                  >
                    Title can't be blank. Pick a status so the ticket lands in the right list.
                  </.alert>
                  <.input
                    id="ticket-title"
                    name="ticket[title]"
                    label="Title"
                    placeholder="Visible progress ring"
                    value={@ticket_form["title"]}
                    errors={Map.get(@ticket_errors, "title", [])}
                  />
                  <.textarea
                    id="ticket-body"
                    name="ticket[body]"
                    label="Description"
                    placeholder="What changes, and how will the reviewer see it?"
                    value={@ticket_form["body"]}
                    help_text="Markdown welcome. Screenshots beat paragraphs."
                  />
                  <.select
                    native
                    id="ticket-status"
                    name="ticket[status]"
                    label="Status"
                    options={[{"To do", "todo"}, {"In progress", "in_progress"}, {"Done", "done"}]}
                    value={@ticket_form["status"]}
                    prompt="Pick a status"
                    errors={Map.get(@ticket_errors, "status", [])}
                  />
                </.stack>
              </form>
              <:footer>
                <.button size="sm" variant="ghost" navigate="/blocks/list">Cancel</.button>
                <.button size="sm" variant="solid" type="submit" form="ticket-form">Create ticket</.button>
              </:footer>
            </.card>
          </.stack>
        </div>
      </article>

      <article :if={@block == "login"} class="docs-body docs-body-wide">
        <p class="docs-eyebrow">Block · copied from lantern-ui recipes</p>
        <div style="max-width: 400px; margin: 3rem auto 0;">
          <.card>
            <.stack gap="md">
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <.icon name="sparkles" />
                <span class="lui-brand-name">Acme</span>
              </div>
              <.page_header title="Welcome back" description="Sign in to your workspace." />
              <.input
                id="login-email"
                name="email"
                type="email"
                label="Email"
                placeholder="ada@acme.test"
                autocomplete="email"
              />
              <.input
                id="login-password"
                name="password"
                type="password"
                label="Password"
                placeholder="••••••••"
                autocomplete="current-password"
                errors={["is incorrect — try again or reset it"]}
              />
              <.button variant="solid" style="width: 100%;" phx-click="demo_login">Sign in</.button>
              <.separator text="or continue with" />
              <.button variant="outline" style="width: 100%;" phx-click="demo_sso">Continue with SSO</.button>
            </.stack>
            <:footer>No account yet? Ask your workspace admin for an invite.</:footer>
          </.card>
        </div>
      </article>

      <article :if={@block == "destructive"} class="docs-body docs-body-wide">
        <p class="docs-eyebrow">Block · copied from lantern-ui recipes</p>
        <div style="max-width: 1120px; margin: 0 auto;">
          <.stack gap="lg">
            <.page_header
              title="Danger zone"
              description="Irreversible actions wait behind a confirmation."
            />
            <.card
              title="Delete workspace"
              description="Removes every ticket, inbox item, and invite. This cannot be undone."
            >
              <.button variant="solid" color="danger" phx-click="open_confirm">Delete workspace…</.button>
            </.card>
            <.alert_dialog id="delete-workspace" open={@confirm_open}>
              <:title>Delete this workspace?</:title>
              <:description>
                Every ticket, inbox item, and invite goes with it. Type the workspace name to confirm.
              </:description>
              <:cancel><.button variant="outline" phx-click="close_confirm">Cancel</.button></:cancel>
              <:action><.button variant="solid" color="danger" phx-click="confirm_delete">Delete workspace</.button></:action>
            </.alert_dialog>
            <.card_grid min="16rem">
              <.card title="Empty">
                <.empty_state icon="document" title="No tickets yet">
                  Create the first one to get the list going.
                  <:action><.button size="sm" variant="solid" navigate="/blocks/form">New ticket</.button></:action>
                </.empty_state>
              </.card>
              <.card title="Loading">
                <.stack gap="sm">
                  <.loading label="Loading tickets…" />
                  <.skeleton style="height: 0.875rem;" />
                  <.skeleton style="height: 0.875rem; width: 62%;" />
                </.stack>
              </.card>
              <.card title="Error">
                <.stack gap="sm">
                  <.alert color="danger" title="Tickets didn't load">
                    The request timed out. Check your connection and try again.
                  </.alert>
                  <div><.button size="sm" variant="outline">Retry</.button></div>
                </.stack>
              </.card>
            </.card_grid>
          </.stack>
        </div>
      </article>
    </DocsShell.shell>
    """
  end
end
