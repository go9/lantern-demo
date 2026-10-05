defmodule LanternDemoWeb.App.Pages.Dashboard do
  @moduledoc "Overview: stat grid, throughput chart, project progress and a filterable activity list."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Helpers
  alias LanternUI.Charts

  @throughput [3, 5, 2, 6, 4, 7, 5, 3, 8, 6, 9, 7, 5, 8]

  def mount_page(socket, _params) do
    sid = socket.assigns.sid
    tickets = Store.list_tickets(sid)
    projects = Store.list_projects(sid)

    today = Date.utc_today()

    series =
      for {v, i} <- Enum.with_index(@throughput) do
        %{date: Date.add(today, i - 13), value: v}
      end

    Phoenix.Component.assign(socket,
      dash_tickets: tickets,
      dash_projects: Enum.map(projects, &project_progress(&1, tickets)),
      dash_series: series,
      activity_filter: Map.get(socket.assigns, :activity_filter, "all")
    )
  end

  defp project_progress(project, tickets) do
    mine = Enum.filter(tickets, &(&1.project_id == project.id))
    Map.merge(project, %{completed: Enum.count(mine, &(&1.status == :done)), scope: length(mine)})
  end

  def crumbs(_), do: [%{label: "Acme", path: "/app"}, %{label: "Dashboard", path: nil}]

  def actions(_) do
    [%{label: "New ticket", navigate: "/app/tickets/new", variant: "solid"}]
  end

  def handle_event("filter_activity", %{"status" => status}, socket) do
    {:noreply, Phoenix.Component.assign(socket, activity_filter: status)}
  end

  def handle_event(_, _, _), do: :unhandled

  defp filtered(tickets, "all"), do: tickets |> Enum.take(8)

  defp filtered(tickets, status),
    do: tickets |> Enum.filter(&(Atom.to_string(&1.status) == status)) |> Enum.take(8)

  defp count(tickets, "all"), do: length(tickets)
  defp count(tickets, status), do: Enum.count(tickets, &(Atom.to_string(&1.status) == status))

  def render(%{view_state: "loading"} = assigns) do
    ~H"""
    <.stack gap="lg">
      <div class="acme-skel-row" aria-busy="true" aria-label="Loading dashboard">
        <.skeleton :for={_ <- 1..4} style="height: 4.5rem;" />
      </div>
      <.skeleton style="height: 16rem;" />
      <.skeleton style="height: 12rem;" />
    </.stack>
    """
  end

  def render(%{view_state: "error"} = assigns) do
    ~H"""
    <.alert color="danger" title="Couldn't load the dashboard">
      The activity service didn't answer. This is a simulated failure.
      <div class="acme-alert-actions"><.button size="sm" variant="outline" patch="/app">Try again</.button></div>
    </.alert>
    """
  end

  def render(assigns) do
    ~H"""
    <.stack gap="lg">
      <.stat_grid>
        <:stat
          label="Open tickets"
          value={@counts.todo + @counts.in_progress}
          subtitle={"#{@counts.urgent} urgent"}
          href="/app/tickets"
        />
        <:stat
          label="In progress"
          value={@counts.in_progress}
          subtitle="being worked on"
          href="/app/tickets?filters[0][field]=status&filters[0][value]=in_progress"
        />
        <:stat
          label="Done"
          value={@counts.done}
          subtitle="all time"
          href="/app/tickets?filters[0][field]=status&filters[0][value]=done"
        />
        <:stat label="Team" value={length(@members)} subtitle="members" href="/app/team" />
      </.stat_grid>

      <.card_grid min="24rem">
        <.card title="Throughput" description="Tickets closed per day, last 14 days">
          <Charts.area_chart id="dash-throughput" series={@dash_series} height={200} />
        </.card>
        <.card title="Projects" description="Done out of total tickets">
          <.stack gap="md">
            <div :for={p <- @dash_projects} class="acme-project-line">
              <.progress shape="ring" completed={p.completed} scope={p.scope} size="sm" label={p.name} />
              <.link patch={"/app/projects/#{p.id}"} class="acme-link">{p.name} <span class="acme-muted">{p.completed}/{p.scope} done</span></.link>
              <span class="acme-muted">{p.summary}</span>
            </div>
          </.stack>
        </.card>
      </.card_grid>

      <.card flush title="Recent activity" description="Newest tickets first">
        <:actions>
          <div class="acme-chips" role="group" aria-label="Filter activity">
            <.button
              :for={{label, key} <- [{"All", "all"}, {"In progress", "in_progress"}, {"To do", "todo"}, {"Done", "done"}]}
              size="sm"
              variant={if @activity_filter == key, do: "solid", else: "outline"}
              phx-click="filter_activity"
              phx-value-status={key}
              aria-pressed={to_string(@activity_filter == key)}
            >
              {label} <span class="acme-chip-count">{count(@dash_tickets, key)}</span>
            </.button>
          </div>
        </:actions>
        <.list_row
          :for={t <- filtered(@dash_tickets, @activity_filter)}
          identifier={t.identifier}
          title={t.title}
          patch={"/app/tickets/#{t.id}"}
        >
          <:leading>
            <.status_glyph status={t.status} label={Helpers.status_label(t.status)} />
            <span class="lui-list-row-status">{Helpers.status_label(t.status)}</span>
          </:leading>
          <:meta><.badge size="sm">{t.tag}</.badge></:meta>
          <:trailing>{Helpers.fmt_date(t.date)}</:trailing>
        </.list_row>
        <.empty_state :if={filtered(@dash_tickets, @activity_filter) == []} icon="inbox" title="Nothing here">
          No tickets with that status yet.
        </.empty_state>
      </.card>
    </.stack>
    """
  end
end
